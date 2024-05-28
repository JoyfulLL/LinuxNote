## Nginx Proxy

- Forward Proxy： user -> Forward Proxy -> google.com
- Reverse Proxy： `user -> Reverse Proxy -> web cluster -> Reverse Proxy -> user`



## 负载均衡模块的选项

- upstream 模块  server 指令支持的选项

```shell
upstream pools {
	server 10.0.1.1:80 weight=2 max_fails=3 fail_timeout=10S;
	server 10.0.1.2:80 weight=1 max_fails=3 fail_timeout=10S;
	server 10.0.1.9:80 backup;
}
```

| 选项             | 说明                                        | 应用场景           |
| ---------------- | ------------------------------------------- | ------------------ |
| **weight**       | 权重，根据权重分配请求                      | 依据服务器配置分配 |
| **max_fails**    | 最大失败次数，超过之后则认为节点宕机        | 一般配置1-3次      |
| **fail_timeout** | 节点宕机后间隔多久再次检查节点状态；默认10S |                    |
| backup           | 备胎服务器，只有所有机器宕机，才会启用      | 注意雪崩的情况     |

> 雪崩：所有负载均衡的web机器全部宕机，将所有请求落在backup服务器，backup无法承受，最终也宕机 --> 雪崩



# 面试题

## 负载均衡和反向代理的区别

> 区别在于处理用户请求的方式

| 内容     | 共同点                   | 区别                                                         | 服务                         |
| -------- | ------------------------ | ------------------------------------------------------------ | ---------------------------- |
| 负载均衡 | 用户的请求分到后端节点上 | user -> load balance -> web  lb做数据转发，不会产生新的请求                            1请求1响应 | lvs                          |
| 反向代理 | 用户的请求分到后端节点上 | user -> Reverse Proxy -> web cluster -> Reverse Proxy -> user   2个请求2个响应  代理代替用户去找web服务器 | ngx/tegine/openresty/haproxy |

![image-20240427204140991](C:\Users\ljf13\AppData\Roaming\Typora\typora-user-images\image-20240427204140991.png)

![image-20240427204126664](C:\Users\ljf13\AppData\Roaming\Typora\typora-user-images\image-20240427204126664.png)
