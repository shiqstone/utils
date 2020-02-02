package main

import (
    "io/ioutil"
    yaml "gopkg.in/yaml.v2"
    "bytes"
    //"fmt"
    "log"
    "path"
    "path/filepath"
    "strings"
    "os"
    "os/exec"
    "database/sql"
    _ "github.com/go-sql-driver/mysql"
    "time"

    "net/http"
    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/credentials"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/s3"

    "sync"

    "github.com/panjf2000/ants"
)

var db *sql.DB
var s *session.Session
//var quit = make(chan int64, 100)

func main() {
    var (
        Config Config
        goSync sync.WaitGroup
    )
    data, err := ioutil.ReadFile("conf/conf.yaml")
    //log.Println(data)
    if err != nil {
        checkErr(err)
    }
    err = yaml.Unmarshal(data, &Config)
    if err != nil {
        checkErr(err)
    }
    //fmt.Println(Config)
    //fmt.Println(Config.Db.Dialect)
    //return

    //user:password@tcp(localhost:5555)/dbname?charset=utf8
    db, err = sql.Open(Config.Db.Dialect, Config.Db.User + "@tcp(" + Config.Db.Host + ":" + Config.Db.Port + ")/" + Config.Db.Database + "?charset=" + Config.Db.Charset)
    checkErr(err)

    //query date
    //rows, err := db.Query("SELECT id, video_s3_url FROM material_video")
    rows, err := db.Query("SELECT id, video_s3_url FROM material_video where video_thumb_url is null")
    checkErr(err)

    access_key := Config.S3.AccessKey
    secret_key := Config.S3.SecretKey
    end_point := Config.S3.EndPoint
    bucket := Config.S3.Bucket
    // Configure to use S3 Server
    s, err = session.NewSession(&aws.Config{
        Region: aws.String("us-west-2"),
        Credentials: credentials.NewStaticCredentials( access_key, secret_key, ""),  // token can be left blank for now
        Endpoint:         aws.String(end_point),
        DisableSSL:       aws.Bool(true),
        S3ForcePathStyle: aws.Bool(true),
    })
    if err != nil {
        checkErr(err)
    }

    defer ants.Release()
    p, _ := ants.NewPoolWithFunc(Config.Pool.MaxNum, func(params interface{}) {
        var id int
        var video_s3_url string
        for k, v := range params.(map[string]interface{}){
            if k == "id" {
                id = v.(int)
            }
            if k == "video_s3_url" {
                video_s3_url = v.(string)
            }
        }
        process(id, video_s3_url, bucket, end_point)
        goSync.Done()
    })
    defer p.Release()
    //quit = make(chan int64)
    cnt := 0
    for rows.Next() {
        var id int
        var video_s3_url string
        err = rows.Scan(&id, &video_s3_url)
        checkErr(err)
        //affect := process(db, id, video_s3_url, s, bucket, end_point)
        //go process(id, video_s3_url, bucket, end_point)
        //process(id, video_s3_url, bucket, end_point)
        //log.Println("affect", affect)

        log.Println(id, video_s3_url, bucket, end_point)
        params := make(map[string]interface{})
        params["id"] = id
        params["video_s3_url"] = video_s3_url

        goSync.Add(1)
        _ = p.Invoke(params)

        cnt++
    }
    log.Println(cnt)

    goSync.Wait()
    //log.Printf("running goroutines: %d\n", ants.Running())
    log.Printf("finish all tasks.\n")
}

func process(id int, video_s3_url string, bucket string, end_point string) int64 {
    fullpath := video_s3_url
    //width := 288
    //height := 512
    fileName := filepath.Base(fullpath)
    fileSuffix := path.Ext(fileName)
    fileSingleName := strings.TrimSuffix(fileName, fileSuffix)
    output := fileSingleName + ".png" 
    log.Println(output)

    //delete exist file
    //_ = os.Remove(output);
    //if err != nil {
    //    log.Println(err)
    //}

    //cmd := exec.Command("ffmpeg", "-i", fullpath, "-vframes", "1", "-s", fmt.Sprintf("%dx%d", width, height), "-f", "singlejpeg", output)
    //fmt.Println("ffmpeg", "-i", fullpath, "-vframes", "1", "-ss", "3", "-t", "1", output)
    log.Println("ffmpeg", "-i", fullpath, "-vframes", "1", "-ss", "3", "-t", "1", output)
    cmd := exec.Command("ffmpeg", "-i", fullpath, "-vframes", "1", "-ss", "3", "-t", "1", output)
    var buffer bytes.Buffer
    cmd.Stdout = &buffer
    if cmd.Run() != nil {
        //panic("could not generate frame")
        log.Println("could not generate frame")
    }

    // Upload
    err := AddFileToS3(bucket, output)
    if err != nil {
        log.Println("could not update to s3")
        checkErr(err)
    }
    log.Println(output, "update to s3")

    thumb_url := end_point + "/" + bucket + "/" + output
    //fmt.Println(thumb_url)

    //update db
    timeStr := time.Now().Format("2006-01-02 15:04:05")
    log.Println("update material_video set video_thumb_url='", thumb_url, "', update_time='", timeStr, "' where id=", id)
    stmt, err := db.Prepare("update material_video set video_thumb_url=?, update_time=? where id=?")
    defer stmt.Close()
    checkErr(err)
    res, err := stmt.Exec(thumb_url, timeStr, id)
    //log.Println("res", res)
    checkErr(err)
    affect, err := res.RowsAffected()
    checkErr(err)
    _ = os.Remove(output);
    //quit <- affect
    return affect
}

func checkErr(err error) {
    if err != nil {
        log.Println(err)
        panic(err)
    }
}

func AddFileToS3(bucket string, fileDir string) error {

    // Open the file for use
    file, err := os.Open(fileDir)
    if err != nil {
        log.Println(err)
        return err
    }
    defer file.Close()

    // Get file size and read the file content into a buffer
    fileInfo, _ := file.Stat()
    var size int64 = fileInfo.Size()
    buffer := make([]byte, size)
    file.Read(buffer)

    // Config settings: this is where you choose the bucket, filename, content-type etc.
    // of the file you're uploading.
    _, err = s3.New(s).PutObject(&s3.PutObjectInput{
        Bucket:               aws.String(bucket),
        Key:                  aws.String(fileDir),
        //ACL:                  aws.String("private"),
        Body:                 bytes.NewReader(buffer),
        ContentLength:        aws.Int64(size),
        ContentType:          aws.String(http.DetectContentType(buffer)),
        ContentDisposition:   aws.String("attachment"),
        ServerSideEncryption: aws.String("AES256"),
    })
    return err
}

type Config struct {
    Db   DBConfigInfo
    S3   S3ConfigInfo
    Pool GoroutinePoolInfo
}

type DBConfigInfo struct {
    Dialect  string `yaml:"dialect"`
    User     string `yaml:"user"`
    Password string `yaml:"password"`
    Host     string `yaml:"host"`
    Port     string `yaml:"port"`
    Database string `yaml:"database"`
    Charset  string `yaml:"charset"`
}

type S3ConfigInfo struct {
    AccessKey     string `yaml:"access_key"`
    SecretKey     string `yaml:"secret_key"`
    EndPoint      string `yaml:"end_point"`
    Bucket        string `yaml:"bucket"`
}

type GoroutinePoolInfo struct {
    MaxNum string `yaml:"max_num"`
}