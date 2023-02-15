# SSL / TLS 类漏洞验证与修复


> 什么是 TLS 和 SSL？
>
> 安全套接层（SSL）和传输层安全（TLS）加密用于通过互联网提供通信安全（传输加密）和来保护网络流量和互联网上的隐私，用于诸如网络，电子邮件，即时消息（IM）和一些虚拟专用网络（VPN）。
>
> 因此，TLS 安全配置很重要，应花时间学习如何识别常见的漏洞和安全配置错误。

使用不安全的 TLS 加密协议，攻击者可以以较小的难度破解加密数据，从而导致用户传输的数据被截取或篡改。

## TLS / SSL 安全测试工具

软件使用 github 的 [testssl.sh](https://github.com/drwetter/testssl.sh) 工具，比如我们测试 `test.domain.xxx` 使用方法有两种：

```bash
# 1. 下载库直接运行
$ git clone --depth 1 https://github.com/drwetter/testssl.sh.git && cd testssl.sh
$ ./testssl.sh test.domain.xxx

# 2. 使用 docker 镜像
$ docker run --rm -it drwetter/testssl.sh test.domain.xxx

# 输出 ssl 及 tls 协议部分可能如下
...
 Testing protocols via sockets except NPN+ALPN

 SSLv2      offered (deprecated)
 SSLv3      offered (deprecated)
 TLS 1      offered (deprecated)
 TLS 1.1    offered (deprecated)
 TLS 1.2    offered (OK)
 TLS 1.3    not offered and downgraded to a weaker protocol
 NPN/SPDY   h2, http/1.1 (advertised)
 ALPN/HTTP2 h2, http/1.1 (offered)
...
```

输出中 `SSLv2 offered (deprecated)` 的部分代表不安全的协议受支持，则需要修复。

## 漏洞修复

由于此漏洞说证书配置有关，所有修复的位置肯定是解 https 这个证书的地方，通常来说就是 `负载均衡` ，比如公司内部的七层 Nginx 负载、云应用的 CLB (本文使用 腾讯云 clb 举例) 等。当然还有一些特殊的站点是 负载均衡为四层的配置转发至服务器上解证书。

### Nginx 七层负载修复

只需在指定站点配置的 `conf` 文件中加上 `ssl_protocols TLSv1.2;` 即可。如下：

```bash
$ cat test.domain.xxx.conf
...
server {
    listen 443 ssl http2;
    server_name test.domain.xxx;

    ssl_certificate /opt/nginx/ssl/1hai.cer;
    ssl_certificate_key /opt/nginx/ssl/1hai.key;
    ssl_protocols TLSv1.2;    # 指定只开启 TLS v1.2
...

$ nginx -t && nginx -s reload
```

### 腾讯云七层 CLB 修复

因为 CLB 底层就是由 Nginx，所以修复思路一样，登录控制台，跳转至 [负载均衡个性化配置](https://console.cloud.tencent.com/clb/config?rid=4)，

{{< figure src="./clb_personal_configuration.png" title="CLB 个性化设置" >}}

{{< figure src="./clb_bind_personal_configuration.png" title="绑定对应的 CLB 实例" >}}

### Windows 服务器负载修复

[在 Windows 注册表中配置 Schannel 协议](https://docs.microsoft.com/zh-cn/dotnet/framework/network-programming/tls#configuring-schannel-protocols-in-the-windows-registry)

可以使用注册表细化控制你的客户端和/或服务器应用协商的协议。 你的应用的网络将遍历 `Schannel`（它是安全通道的另一个名称）。 通过配置 `Schannel`，可以配置你的应用的行为。

从 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols` 注册表项开始。 在该注册表项下，可以在集 `SSL 2.0`、`SSL 3.0`、`TLS 1.0`、`TLS 1.1` 和 `TLS 1.2` 中创建任何子项。 在每个子项下，可以创建子项 `Client` 和/或 `Server。` 在 `Client` 和 `Server` 下，可创建 `DWORD` 值 `DisabledByDefault`（0 或 1）和 `Enabled`（0 或 1）。

更具体的介绍及操作跳转至，[管理 AD FS 的 SSL/TLS 协议和密码套件](https://docs.microsoft.com/zh-cn/windows-server/identity/ad-fs/operations/manage-ssl-protocols-in-ad-fs)

#### 修复脚本

修复脚本依据上诉的介绍，脚本使用 powershell 编写，修改注册表 (`win+r` 运行 `regedit`) 实现。

脚本直接在 `powershell` 中运行即可:

```powershell
$protocalPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

$allProtocals = @("SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1")
$endpoints = @("Server", "Client")

foreach ($p in $allProtocals) {
    foreach ($e in $endpoints) {
        $path = "$protocalPath\$p\$e"
        New-Item $path -Force | Out-Null
        New-ItemProperty -Path $path -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -Path $path -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
    }
    Write-Host "$p has been disabled."
}
```

脚本地址: [disable_ssl_tls.ps1](./disable_ssl_tls.ps1)

且上诉脚本我已做成远程链接执行的方式:

```powershell
# 服务器 powershell 命令行
$ iex (irm https://yongsangun.github.io/ssl-tls_protocols/disable_ssl_tls.ps1)
```

注意，**最后需要下线对应的服务器重启** 才可以生效。

