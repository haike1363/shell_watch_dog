# 基于shell的可复用看门狗脚本
可同时Watch多个程序，不同的程序配置不同的接口文件watch_app.conf  
注意：每个接口文件watch_app.conf其中APP_NAME必须唯一
## 接入步骤

- 配置watch_app.conf

```

	#实现启动进程接口
	start_proc() {
	  nohup sleep 1d 2>&1 1>/dev/null &
	}
	
	#实现返回进程PID接口,放到规定变量PID_RET
	get_pid() {
	  PID_RET=`ps -ef | grep "sleep" | grep "1d" | awk '{print $2}'`
	}
	
	#实现结束进程接口，${1}为传入的进程号
	stop_proc() {
	  kill -9 ${1}
	}
	
	#定义程序名，必须唯一
	APP_NAME="sleep1d"
```

- 启动程序同时拉取看门狗  

```

	$sh run_watch.sh start
	start sleep1d ok pid 20722
	start sleep1d watch ok pid 20734
```

- 查看程序启动状态  

```

	$sh run_watch.sh status
	sleep1d is running pid 20722
	sleep1d watch is running pid 20734

```  

- 结束程序同时结束看门狗Shell  

```

	$sh run_watch.sh stop
	stop watch sleep1d pid 20734 ok
	stop sleep1d pid 20722 ok
	
	$sh run_watch.sh status
	sleep1d is not running
	sleep1d watch is not running

```

## [看门狗脚本GIT](https://github.com/haike1363/shell_watch_dog)
