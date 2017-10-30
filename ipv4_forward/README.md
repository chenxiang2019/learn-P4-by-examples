# 开始P4编程之旅

本例主要对P4语言(14版本)的几个组成部分：
- (1)Header，首部；
- (2)Parser，解析器；
- (3)Table，流表；
- (4)Control Flow，流控制程序 

进行说明。

## 背景介绍

P4语言：
- [P4编程详解](http://www.sdnlab.com/17882.html)
- [《P4语言规范》Header & Instances详解](http://www.sdnlab.com/17955.html)
- [《P4语言规范》parser详解 ](http://www.sdnlab.com/18021.html)

传统网络知识：
- 最长前缀匹配：[百度百科 - 最长前缀匹配](https://baike.baidu.com/item/%E6%9C%80%E9%95%BF%E5%89%8D%E7%BC%80%E5%8C%B9%E9%85%8D/5488072?fr=aladdin)；
- IPv4首部结构：[百度百科 - IPv4](https://baike.baidu.com/item/IPv4/422599?fr=aladdin)；
- 以太网帧结构：[百度百科 - 以太网帧格式](https://baike.baidu.com/item/%E4%BB%A5%E5%A4%AA%E7%BD%91%E5%B8%A7%E6%A0%BC%E5%BC%8F/10290427?fr=aladdin)

基于上述背景，本实验将通过P4语言实现一个简单的、基于IPv4转发的交换机处理过程。

## 实验准备

- 网络仿真模拟器Mininet；
- P4编译器p4c-bm；
- P4软件交换机BMv2

## 实验拓扑

两台主机：h1, h2；其中
- h1的IP地址为`10.0.0.1`，MAC地址为`00:00:00:00:00:01`；
- h2的IP地址为`10.0.0.2`，MAC地址为`00:00:00:00:00:02`。

一台P4交换机：s1.

h1与s1的端口1相连，h2与s2的端口2相连。如图所示：

```
h1 <---> s1 <---> h2
```

## P4交换机行为简述

1.根据数据报的首部结构，如以太网帧首部结构，进行状态转移，解析数据报；

2.判断数据报是否为IPv4数据报，是的话进行流表匹配，不是的话不进行操作；

3.针对IPv4数据报，交换机中的"l3_forward"流表使用最长前缀位匹配的方法，匹配数据报的目的IP地址，执行相关动作，如转发或丢包。

## P4程序

现在，编写属于你自己的第一个P4程序。为简化不必要的工作流程，我们提供了基本的程序框架：[switch.p4](p4src/switch.p4)，你只需要补充以下内容：

- [L28](p4src/switch.p4#L28): 补充以太网帧的首部定义，包括48位的源MAC地址、48位的目的MAC地址，以及16位的以太网帧类型；
- [L91](p4src/switch.p4#L91): 当以太网帧类型为`0x0800`时，将解析器的当前状态转移至处理IPv4首部的解析状态；
- [L152](p4src/switch.p4#L152): 在流表"l3_forward"中，使用最长前缀匹配方法，对数据报IPv4首部中的目的IP地址进行匹配；
- [L162](p4src/switch.p4#L162): 在流控制程序中，判断数据报中的IPv4首部是否合法。

注：可以使用`p4-validate switch.p4`判断程序的正确性。

我们在[solution/](solution/)目录下放置了完整的P4程序，在完成之后可以将你所写的P4程序与之进行对比。

## 运行

接着，启动Mininet，模拟本次实验的拓扑环境：

```
$ ./run_14_demo.sh
```

新打开一个终端，为P4交换机增添流表项：

```
$ ./set_switch.sh
```

在Mininet的终端中执行：

```
mininet> h1 ping h2
```

如果ping通，恭喜你，你完成了本次实验。

## 思考

我们是如何向P4交换机中的流表下发表项的？

## 下一步

尝试实例：[counter](https://github.com/Wasdns/learn-P4-by-examples/blob/master/counter)。

