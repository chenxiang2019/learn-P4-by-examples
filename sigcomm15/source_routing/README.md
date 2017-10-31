## Exercise 1: Source Routing

进入`source_routing`目录。

本次实验，我们将通过P4实现一个非常简单的源路由协议，我们将其称为`EasyRoute`。您将会
亲自设计P4程序，当然您也可以重用在p4lang组织下其他项目的代码。您将创建一个Mininet网
络并通过在主机之间发送消息以验证您的实现是否正确。我们提供了程序的骨架:
[p4src/source_routing.p4](p4src/source_routing.p4),
您需要实现程序中的parser部分和ingress控制流部分。

### Description of the EasyRoute protocol

EasyRoute的数据报结构如下：

```
preamble (8 bytes) | num_valid (4 bytes) | port_1 (1 byte) | port_2 (1 byte) |
... | port_n (1 byte) | payload
```

`preamble`字段总是设置为0。您可以使用该字段来区别您的交换机所接收到的EasyRoute数据报
和其他数据报(比如以太网帧)。我们无法保证您的P4交换机仅收到EasyRoute数据报。

`num_valid`字段指明了在该首部中合法端口的数目。如果您的EasyRoute数据报将穿过3台交换机，
那么`num_valid`字段将会被初始化为3，同时数据报中端口列表的长度将会是3字节。当交换机接收
到一个EasyRoute数据报，列表中的第一个端口将被用于决定该数据报的输出端口。`num_valid`字
段的值将减一，同时第一个端口将从将被从数据报端口列表中移除。

我们将使用EasyRoute协议发送文本消息，数据报的数据将会因此对应于我们所发送的文本消息。您
无需担心文本消息的编码。

![Source Routing topology](https://github.com/Wasdns/learn-P4-by-examples/blob/master/sigcomm15/resources/images/source_routing_topology.png)

当我希望在主机h1向主机h3发送消息"Hello"时，EasyRoute数据报将会是以下格式。

- 当数据报离开h1时:
`00000000 00000000 | 00000002 | 03 | 01 | Hello`

- 当数据报离开sw1交换机时:
`00000000 00000000 | 00000001 | 01 | Hello`

- 当数据报离开sw3交换机时:
`00000000 00000000 | 00000000 | Hello`

注意，数据报所经过的最后一台交换机不会将EasyRoute首部移除；否则在终端主机处的应用
无法正确处理接收的数据报。

您的P4代码需要具备以下要求：

1.所有非EasyRoute协议的数据报将被丢弃。

2.如果交换机接收到一个`num_valid`字段为0的EasyRoute数据报，这个数据报将会被丢弃。

### A few hints

1.在start解析状态时，您可以使用`current()`来检查数据报是否是一个EasyRoute协议数据报。
调用`current(0, 64)`将会**在不移动数据报指针的前提下**检查数据报的前64位。

2.请不要忘记，一张流表能够匹配一个数据报首部的合法性。进一步说，如果一个首部非法，那
我们的软件交换机会将位于该首部中的所有字段置为0.

3.一张流表可以“匹配”一个空的键值，如果运行时配置正确的话 - 这意味着该流表始终执行它的
默认动作。只要在编写代码的过程中忽略掉`reads`属性即可实现。

4.您可以通过调用`remove_header()`移除掉数据报中的一个首部。

5.当解析EasyRoute首部时，您无需解析一整个端口列表。事实上，目前P4语言缺少用于解析一般
Type-Length-Value(TLV)类型首部的语言结构。因此，您将需要简单地解析列表中的第一个端口，
并忽略掉剩下的内容(包括数据)。此外，`num_valid`和端口号无需放置在同一个首部类型中。

6.最后，我们建议您将您的P4程序逻辑放置于ingress流控制程序中，并将egress流控制程序置空。
您无需定义超过1到2张的流表来实现EasyRoute协议。

### Populating the tables

一旦您的P4程序准备好了(您可以通过运行`p4-validate`来检验您的程序是否正确)，您需要
考虑如何为这些流表加入对应的表项。我们为您提供了一种简单的途径：您只需要将`bmv2`
CLI的命令填入commands.txt文件即可。我们认为您只需要了解两种命令：

- `table_set_default <table_name> <action_name> [action_data]`: 该命令用于设置给定
流表的默认动作。
- `table_add <table_name> <action_name> <match_fields> => [action_data]`: 该命令用
于为流表加入一条表项。

您可以在`flowlet_switching`目录下查看样例命令: 
[flowlet_switching/commands.txt](../flowlet_switching/commands.txt) 并将它们和对应的P4
流表相匹配:
[flowlet_switching/p4src/simple_router.p4](../flowlet_switching/p4src/simple_router.p4).

### Testing your code

`./run_demo.sh`将编译您的代码，并创建上述的Mininet网络。它会使用commands.txt来配置每一
台交换机。一旦网络启动并开始运行，您应在Mininet的CLI中键入以下的内容:

- `xterm h1`
- `xterm h3`

这些命令将会分别再h1和h3上启动一个终端。

On h3 run: `./receive.py`.

On h1 run: `./send.py h1 h3`.

在此之后，您应该能够在h1的终端上输入消息，并在h3处接收到它们。`send.py`程序将会使用
Dijkstra算法找到h1和h3之间的最短路径，并发送正确格式的数据报穿过s1和s3.

### Debugging your code

对于每一个接口来说都会生成一个对应的`.pcap`文件(9个，每台交换机3个，共3台交换机)。
您可以查看合适的文件并检查您的数据报是否被正确处理。
