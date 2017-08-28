---
title: "《TCP/IP详解》网络层总结"
date: 2017-03-25T14:40:00+08:00
tags: ["network"]
categories: ["network"]
---

#  IP协议层概述
通过数据包的目标IP地址，不断得找出通往该IP地址的路由器（下一跳路由器地址），并最终将数据包送到目标机器上的协议层。本质的功效是导航数据包去往目标机器。 

<!--more-->

![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/001.png)


# 网络分层架构简述
## IP地址介绍
#### 概述
ip地址由网络号和主机号组合而成，网络号标记一个网络，主机号则为这个网络内的用于标记主机地址的号码。为了避免ip浪费，后面出现了子网划分和子网掩码，比如一个B类地址为140.128.0.0，子网划分为8位。那么其子网掩码则为255.255.255.0。例如有一个数据包要发送到140.128.3.123，数据包送达连接148.128.0.0的路由器后，使用子网掩码与IP逐位与操作得到140.128.3.0的子网地址。数据包先被送到这个子网，然后再被送到该子网上特定的主机上。
#### 分类IP地址
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/002.png)
#### 分类IP地址范围
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/003.png)
#### 无分类编址
前缀为网络号，余下部分为主机号，为了更好地充分利用ip地址，减缓ip地址过早耗尽采用的策略，可以理解为划分子网的进一步改进

## 网络结构简述
#### ip地址管理
ip地址由其管理机构，统一批量发给一些大的ISP（Internet Service Provider）机构，不同的ISP再将自己拿到的ip，再分给不同的规模更小的ISP机构，这些机构再将ip分给众多本地ISP，绝大多数用户是通过本地ISP接入互联网的，层次结构图如下所示：    
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/004.png)    

#### 区域自治与边界路由
ip数据包，要发送到目的端，要经过若干个路由器，到达路由器时，需要查询路由表中的目的地址，以及下一跳路由器的地址，但是因特网上网络众多，如果所有的网络号都放置于同一层级上，将会使路由表变得异常庞大，直接影响网络的传输性能，因此需要将不同地区的网络划分为若干个自治系统（autonomous system），自治系统内的路由器的路由表包含整个自治系统各个网络的信息，自治系统之间又通过边界路由器连接在一起。
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/005.png)

自治系统由各ISP自行组建，规模较小的自治系统内任何一个路由器的路由表中，标记到达本自治系统任何一个网络的信息（大的自治系统还会分为若干个区域，区域之间通过边界路由器连接）。自治系统内采用自己的路由选择协议（RIP或OSPF），自治系统之间采用BGP路由选择协议（AS边界路由一般叫做BGP发言人）。
数据包发送到网络时，首先会发送到本机所属的本地自治系统中，通过路由表查找目的地址对应的下一跳路由器ip地址，如果找不到，则通过默认路由，将数据包发往边界路由器，传往上一级AS，地区自治系统，地区自治系统中的路由器如果找到目的地址，则派往相应的本地AS中，如果找不到则再往上发送到主干网，因为必须能够让任何有效的ip地址，都能找到匹配的目的地址【《计算机网络》P157】，再由主干网通过边界路由器发往对应的地区自制系统中，进而再发送到本地自治系统，最后找到指定的网络、指定的主机并将数据包交付。

## IP数据包
#### 首部结构图
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/006.png)    

* 版本：标识是使用ipv4或者是ipv6协议
* 首部长度：标记IP数据包首部总长是多少，单位是4字节，最长是60字节
* TOS服务类型：进行路由决策的字段，头3位标志优先权现已弃用，最后一位未使用但是必须是0，中间四位分表标记最小延时、最大吞吐量、最高可靠性和最小费用。下图是各种应用的TOS建议字段![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/007.png)
* 总长度：标记IP数据包首部和数据部分的总长，通过首部长度和数据包总长度能够推算出数据包的起始地址和结束地址（不是指未分片前的长度，而是分片后的长度）
* 16位标识：唯一标识所有发出的IP数据包，每次发送时，标识+1，当ip数据包因为超过MTU需要进行分片时，所有分片的标识值都被赋值为相同的值，为后面重组数据包提供依据
* 3位标志：001表示后面还有分片（More Fragment），010表示不能分片（Don't Fragment）
* 片偏移字段：较长的ip数据包进行分片后，用来标记该数据包相对于用户数据起点的偏移地址是多少。
* TTL：数据包生存周期，发送IP数据包时时设定，每经过一个路由器，该值减1，当值为0时，数据包被丢弃
* 8位协议：标记是哪层协议向IP层发送数据包（TCP或UDP）

协议名 | ICMP | IGMP | TCP | EGP | IGP | UDP | ipv6 | OSPF
---|---|---|---|---|---|---|---|---
协议字段值 | 1 | 2 | 6 | 8 | 9 | 17 | 41 | 89

* 首部校验和：判断IP数据包是否有效数据包的字段

#### 路由表
目的地址 | 距离 | 子网掩码 | 下一跳地址
---|---|---|---
目的网络地址|相隔多少个路由器|各个网络自行决定|下一个路由器的ip地址

#### 路由寻址算法
* 解析IP数据包首部，提取目的IP地址为D，得出目的网络为N（通过子网掩码按位与运算得出）
* 判断网络N是否与当前路由器直接相连，如果是则直接交付数据包到相连网络，否则执行下一步
* 判断IP地址D是否是特定路由地址，如果是则交付下一跳地址，否则执行下一步
* 判断网络N是否在，能否找到下一跳地址，如果能则交付给下一跳路由器
* 查找默认路由，交付下一跳路由器，找不到则进行下一步
* 放弃数据包，报告转发分组出错

## ICMP协议
#### 作用
为了更好得交付IP数据包（提高成功交付的机会），采用的网络控制协议。主要将ip数据包在传输过程中的错误信息或者查询信息返回给源端。本质上是对ip数据包状况的一种反馈
#### ICMP数据包格式
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/008.png)    
ICMP数据包首部的第5~8字节中，有两个字节是标识符，剩下两个字节是序号，ICMP报文中的标识符和序列号字段由发送端任意选择设定，这些值在应答中将被返回，这样，发送端就可以把应答与请求进行匹配。
#### ICMP数据包分类和代码详细信息
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/009.png)    
![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/010.png)    

* 终点不可达：当主机或路由器不能交付数据包时，则向源点发送不可达报文
* 源点抑制：当路由器或主机由于拥塞放弃数据包时，则向源点发送源点抑制报文，让源点知道要放慢发送速率
* 时间超过：当路由器收到的数据包TTL为0时，除了要丢弃数据包以外，还需要向源点发送超时报文。此外，当目的端在规定时间内收不齐数据包，也会将已经收到的所有数据包丢弃，并向源点返回时间超过报文
* 参数问题：当数据包首部参数设置不正确时，则向源点发送参数问题数据包
* 改变路由：路由器把改变路由的数据包发送给主机，让主机知道数据要转发到其他的路由器中（选择更好的路由路径）   

#### ICMP数据包分类
* 差错报文
    * 报文格式![image](https://raw.githubusercontent.com/Manistein/Photos/master/DailyUse/network_study/ipprotocol/011.png)
    * 以下几种情况，不发送ICMP错误报文
        * ICMP差错报文本身出错，不会返回（避免永无休止的错误反馈）
        * 非首个ip数据包分片出错，不返回
        * ip数据包地址为多播地址的数据包
        * ip数据包包含特殊地址，如127.0.0.0（环回地址）或0.0.0.0
* 查询报文（使用例子）
    * ping程序（检测目的地是否可达）
    * traceroute程序（输出路由路径）
    * traceroute算法：
        * 首先发送无法交付的UDP包，TTL设置为1，第一个路由器收到后，TTL减去1得到0，返回超时ICMP差错
        * 发送UDP包，TTL设置为2，第二个路由器收到后，TTL为0，返回超时差错包
        * 不断循环，直到数据包达到目的地，因为UDP包无法交付，则返回数据包不可达错误
        * 源端得到完整的输出路径