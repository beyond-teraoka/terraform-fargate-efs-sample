# WordPress DBユーザー設定
```
$ CREATE DATABASE wordpress;
$ CREATE USER 'wordpress'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
$ GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@'%';
$ GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@'localhost';
```