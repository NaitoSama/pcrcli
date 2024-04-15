# pcrcli

公主连结会战客户端

## 介绍

出刀、尾刀、撤回、我进了、我出了、挂树、下树、调整状态、出刀记录功能全部可用。只有管理员才能使用调整boss状态（调整后会自动清空挂树和进入了的成员，会被撤刀导致调整失效并回到出刀前状态）。

出刀通信使用websocket，实时性更高。

boss图片只能由管理员更改，头像只能通过“我的页面”更改。

需要结合[服务端](https://github.com/NaitoSama/pcrclanbattle_server)使用。

## 示例服务器

下载release版本，服务器的地址是cb.pekopekopeko.site，服务器版本为服务端release最新版本，需要客户端对应版本才能使用。服务端用的日本服务器，可能连接速度比较慢。注册码为"peko"(不带引号)。

## 预览图

![主页面](https://raw.githubusercontent.com/NaitoSama/pcrcli/master/screenshot/v1.0.3%2B2%20Main.jpg)
![我的页面](https://raw.githubusercontent.com/NaitoSama/pcrcli/master/screenshot/v1.0.3%2B2%20Mine.jpg)
![出刀记录](https://raw.githubusercontent.com/NaitoSama/pcrcli/master/screenshot/v1.0.3%2B2%20Records.jpg)