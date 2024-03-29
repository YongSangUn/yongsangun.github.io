# 正则表达式入门


> 这里所说的正则表达式在实际使用中 ，shell 亦或是 python，都会有使用上的差异，但思路不变。
> 如果需要查看语言或者环境对应的语法，推荐下面的站点：[菜鸟-正则表达式](https://www.runoob.com/?s=%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F&page=1)，不一定全，也收录了不少。
> 在使用中可以使用下面的站点测试正则表达式 [正则表达式在线测试](https://c.runoob.com/front-end/854), 在站点下方有很多示例供参考。

## 什么是正则表达式

在编写处理字符串的程序或者网页时，经常会有查找符合某些复杂规则的字符串的需要。**正则表达式**就是描述这些规则的工具（记录文本规则的代码）。

**通配符（wildcard）**，也就是\*和?。

> `*` 代表零个、单个或者多个字符。
>
> `?` 代表单个字符。

## 常用的元符号

| 代码 | 说明                               |
| ---- | ---------------------------------- |
| \w   | 匹配字母或者数字或者下划线或者汉字 |
| \s   | 匹配任意的空白符                   |
| \d   | 匹配数字                           |
| \b   | 匹配单词的开头和结尾               |
| ^    | 匹配字符串的开始                   |
| &    | 匹配字符串的结束                   |

例：

- `\ba\w*\b` 匹配以字母 a 开头的单词
- `\d+` 匹配一个或多个连续的数字。（ + 类似 _ ，但是 _ 匹配的是重复任意次，而 + 则匹配 1 次以上）。
- `\b\w{6}\b` 匹配刚好 6 个字符的单词
- `^\d{5,12}$` 可以用来**匹配 QQ 号的 5 至 12 位数字**

## 字符转义

匹配 符号 ".", "\*" 等，需要转义使用 \ 。

例：

- `deerchao\.net` 匹配 deerchao.net
- `C:\\Windows` 匹配 C:\Windows 。

## 重复

限定符（指定数量的代码，例如\*，{5,12}等）:
常用的限定符：

| 代码/语法 | 说明               |
| --------- | ------------------ |
| -         | 重复零次或者更多次 |
| \*        | 重复一次或者更多次 |
| ?         | 重复零次或者一次   |
| {n}       | 重复 n 次          |
| {n,}      | 重复 n 次或更多次  |
| {n,m}     | 重复 n 到 m 次     |

例：

- `Windows\d+` 匹配 Windows 后面的 1 个或者更多数字
- `^\w+` 匹配一行的第一个单词

## 字符类

匹配没有预定义元字符的字符集合（比如元音字母 a, e, i, o, u ）,将它们放入 [ ] 中即可。

例：

- `[aeiou]` 匹配任何一个元音字母
- `[.?!]` 匹配标点符号……
  也可以指定一个字符范围，

- `[0-9]` 代表的含义与 `\d` 完全一致的 **一位数字**；
- `[a-z0-9A-Z]` 等同于 `\w`
- **更复杂的一个表达式** `\(?0\d{2}[) -]?\d{8}`

  这个表达式可以匹配++几种格式的电话号码++，像(010)88886666，或 022-22334455，或 02912345678 等。我们对它进行一些分析吧：首先是一个转义字符\(,它能出现 0 次或 1 次(?),然后是一个 0，后面跟着 2 个数字(\d{2})，然后是)或-或空格中的一个，它出现 1 次或不出现(?)，最后是 8 个数字(\d{8})。

- 括号 `"("`和`")"` 也是元字符，后面的分组节里会提到，所以在这里需要使用转义。

## 分支条件

上一个表达式也可以匹配 010)123456789 或者 (022-87654321 这样“不正确”的格式。

所以可以设置**分支条件**。如果满足任何一种规则就匹配，使用 | 把不同的规则分隔开。

例：

- `0\d{2}-\d{8}|d{3}-\d{7}` 匹配连两种格式电话号码： 三位区号 8 位本地号 (022-12345678) ； 或者四位区号 7 位本地号 (0223-1234567)。
- `\(0\d{2}\)[- ]?\d{8}|0\d[2][- ]?\d{8}` 匹配 3 位区号的电话号码，区号可以不用括号，区号与本地号连接 - 空格或者不用间隔。
- `\d{5}-\d{4}|d{5}` 匹配美国的邮政编码（美国的邮政编码规则是，5 位数字，或者用连字号间隔的 9 个数字 12345 or 12345-6789）。

  **要注意各个条件的顺序**。如果你把它改成 `\d{5}|\d{5}-\d{4}` 的话，那么就只会匹配 5 位的邮编(以及 9 位邮编的前 5 位)。原因是匹配分枝条件时，将会从左到右地测试每个条件，如果满足了某个分枝的话，就不会去再管其它的条件了。

## 分组

实现重复多个字符，可以使用小括号来指定**子表达式**（也叫做分组）

例：

- `(\d{1,3}\.){3}\d{1,3}` 简单的 IP 地址匹配表达式， 将 `(\d{1,3}\.)`重复 3 次 最后加上`(\d{1,3}\.)`。

但上式会匹配到 256.300.888.999 所以需要用字符类来精准描述。

```code
((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]|\d25[0-5]|[01]?\d\d?)
```

理解表达式主要是理解 `2[0-4]\d|25[0-5]|[01]?\d\d?` ， 它们分别匹配 200~240，250~255，0~199.

## 反义

常用的反义代码：
代码/语法 | 说明
--- | ---
\W | 匹配任意不是字母，数字，下划线，汉字的字符
\S | 匹配任意不是空白符的字符
\D | 匹配任意非数字的字符
\B | 匹配不是单词开头或结束的位置
[^x] | 匹配除了 x 以外的任意字符
[^aeiou] | 匹配除了 aeiou 这几个字母以外的任意字符

例：

- `\S+` 匹配不包含空白符的字符串。
- `<a[^>]+>` 匹配用尖括号括起来的以 a 开头的字符串。

## 后向引用

用于重复搜索前面某个分组匹配的文本。
使用小括号 “ (……) ”指定的一个表达式，需要匹配这个表达式的文本进一步处理，则会给每个表达式分配一个**组号**，从左向右，第一个出现的为 1 ,第二个为 2 ....
例如：`\1` 就代表 +分组 1 匹配的文本。

组号分配不至说的那么简单：

- 分组 0 对应整个正则表达式
- 实际上组号分配过程是要从左向右扫描两遍的：第一遍只给未命名组分配，第二遍只给命名组分配－－因此所有命名组的组号都大于未命名的组号
- 你可以使用(?:exp)这样的语法来剥夺一个分组对组号分配的参与权．
  `\b(\w+)\b\s+\1\b`就代表匹配 重复的单词， `\b(\w+)\b` 匹配单词，包括\b 单词的开始处和结束处， 这个单词编号为 1， 后面 `\1\b` 重复。

- 也可以指定组名：
  `(?<Word>\w+)` 或者 `(?'Word'\w+)`, 使用 `\k<Word>`引用。
  上式可写成，`\b(?<Word>\w+)\b\s+\k<Word>\b`。

小括号还有很多特定用途的语法。

**常用的分组语法：**

<table>
    <tr>
        <td>分类</td>
        <td>代码/语法</td>
        <td>说明</td>
    </tr>
    <tr>
        <td rowspan="3">捕获</td>
        <td>(exp)</td>
        <td>匹配exp,并捕获文本到自动命名的组里</td>
    </tr>
    <tr>
        <td>(?<name>exp)</td>
        <td>匹配exp,并捕获文本到名称为name的组里，也可以写成(?'name'exp)</td>
    </tr>
    <tr>
        <td>(?:exp)</td>
        <td>匹配exp,不捕获匹配的文本，也不给此分组分配组号</td>
    </tr>
    <tr>
        <td rowspan="4">零宽断言</td>
        <td>(?=exp)</td>
        <td>匹配exp前面的位置</td>
    </tr>
    <tr>
        <td>(?<=exp)</td>
        <td>匹配exp后面的位置</td>
    </tr>
    <tr>
        <td>(?!exp)</td>
        <td>匹配后面跟的不是exp的位置</td>
    </tr>
    <tr>
        <td>(?<!exp)</td>
        <td>匹配前面不是exp的位置</td>
    </tr>
    <tr>
        <td>注释</td>
        <td>(?#comment)</td>
        <td>这种类型的分组不对正则表达式的处理产生任何影响，用于提供注释让人阅读</td>
    </tr>
</table>

### 零宽断言

需要查找某些内容（但并不包括这些内容）之前或者之后的东西，例如匹配 \b, ^, \$ 这样的位置（断言），所以称为**零宽断言**。
首先我们需要匹配一个位置，然后匹配之前或者之后的东西。例：

- `(?=exp)` 也叫**零宽度正预测先行断言**，匹配断言处，后面的表达式 exp。

  `\b\w+(?=ing\b)` 会匹配以 ing 结尾的单词的前面部分（除了 ing 以外的部分），如查找 I'm working hard. 会匹配 work

- `(?<=exp)` 也叫**零宽度正回顾后发断言**，匹配断言处，前面的表达式 exp。

  - `\b\w+(?<=wo\b)` 会匹配以 ing 结尾的单词的前面部分（除了 ing 以外的部分），如查找 I'm working hard. 会匹配 rking
  - `\b\w+(?=ing\b)` 会匹配以 ing 结尾的单词的前面部分（除了 ing 以外的部分），如查找 I'm working hard. 会匹配 work

### 负向零宽断言

确保某个字符没有出现（前面说到的反义），但又不想去匹配它，
例如：匹配一个**后面不是字母 u 的字母 q**的单词：

> `\b\w*q[^u]\w*\b` ,但是当 q 出现在结尾 lraq，Benq， 这样就会出错。 `[^u]` 总会匹配一个字符，q 为最后一个字符的话就会出现错误，匹配下一个单词，例如 lraq fighting 。

**负向零宽断言**能解决这样的问题，因为它只匹配一个位置，并不消费任何字符。现在，我们可以这样来解决这个问题：`\b\w*q(?!u)\w*\b` 。

- 零宽度负预测先行断言 `(?!exp)` ，断言此位置的后面不能匹配表达式 exp。

例:

- `\d{3}(?!\d)` 匹配三位数字，而且这三位数字的后面不能是数字；
- `\b((?!abc)\w)+\b` 匹配不包含连续字符串 abc 的单词。
- 零宽度负回顾后发断言 `(?<!exp)` , 来断言此位置的前面不能匹配表达式 exp ：`(?<![a-z])\d{7}` 匹配前面不是小写字母的七位数字。

- `(?<=<(\w+)>).*(?=<\/\1>)`匹配不包含属性的简单 HTML 标签内里的内容。 `(?<=<(\w+)>)` 指定了这样的**前缀**：被尖括号括起来的单词(比如可能是 `<b>)` ，然后是 `.*` (任意的字符串),最后是一个后缀 `(?=<\/\1>)`。

注意后缀里的 `\/` ，它用到了前面提过的字符转义；`\1` 则是一个反向引用，引用的正是捕获的第一组，前面的 `(\w+)` 匹配的内容，这样如果前缀实际上是 `<b>` 的话，后缀就是 `</b>` 了。整个表达式匹配的是 `<b>` 和 `</b>` 之间的内容(再次提醒，不包括前缀和后缀本身)。

### 注释

通过语法(?#comment)来包含注释。
例如：

```c
2[0-4]\d(?#200-249)|25[0-5](?#250-255)|[01]?\d\d?(?#0-199)
```

### 贪婪与懒惰

- 贪婪匹配--尽可能多的匹配

`a.*b` 匹配最长的以 a 开头，b 结束的字符串。 如果匹配 aabab ，它会匹配最长的 aabab。

- 懒惰匹配--尽可能少的匹配

`a.*?b` 匹配最短的 a 开头，b 结束的字符串。 同样的 aabab ，它会匹配 aab，以及 ab。

> 懒惰限定符
>
> | 代码/语法 | 说明                              |
> | --------- | --------------------------------- |
> | \*?       | 重复任意次,但尽可能少重复         |
> | +?        | 重复 1 次或更多次，但尽可能少重复 |
> | ??        | 重复 0 次或 1 次，但尽可能少重复  |
> | {n,m}?    | 重复 n 到 m 次，但尽可能少重复    |
> | {n,}?     | 重复 n 以上，但尽可能少重复       |

### 其他一些语法

| 代码/语法     | 说明                                             |
| ------------- | ------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| \a            | 报警字符(打印它的效果是电脑嘀一声)               |
| \b            | 通常是单词分界位置，但如果在字符类里使用代表退格 |
| \t            | 制表符，Tab                                      |
| \r            | 回车                                             |
| \v            | 竖向制表符                                       |
| \f            | 换页符                                           |
| \n            | 换行符                                           |
| \e            | Escape                                           |
| \0nn          | ASCII 代码中八进制代码为 nn 的字符               |
| \xnn          | ASCII 代码中十六进制代码为 nn 的字符             |
| \unnnn        | Unicode 代码中十六进制代码为 nnnn 的字符         |
| \cN           | ASCII 控制字符。比如\cC 代表 Ctrl+C              |
| \A            | 字符串开头(类似^，但不受处理多行选项的影响)      |
| \Z            | 字符串结尾或行尾(不受处理多行选项的影响)         |
| \z            | 字符串结尾(类似\$，但不受处理多行选项的影响)     |
| \G            | 当前搜索的开头                                   |
| \p{name}      | Unicode 中命名为 name 的字符类，例如\p{IsGreek}  |
| (?>exp)       | 贪婪子表达式                                     |
| (?<x>-<y>exp) | 平衡组                                           |
| (?im-nsx:exp) | 在子表达式 exp 中改变处理选项                    |
| (?im-nsx)     | 为表达式后面的部分改变处理选项                   |
| (?(exp)yes    | no)                                              | 把 exp 当作零宽正向先行断言，如果在这个位置能匹配，使用 yes 作为此组的表达式；否则使用 no |
| (?(exp)yes)   | 同上，只是使用空表达式作为 no                    |
| (?(name)yes   | no)                                              | 如果命名为 name 的组捕获到了内容，使用 yes 作为表达式；否则使用 no                        |
| (?(name)yes)  | 同上，只是使用空表达式作为 no                    |

---

## 相关站点

> [msdn 的正则表达式语言 - 快速参考](https://docs.microsoft.com/zh-cn/dotnet/standard/base-types/regular-expression-language-quick-reference)
>
> [正则表达式 - 教程|菜鸟教程](http://www.runoob.com/regexp/regexp-tutorial.html)
>
> [正则表达式在线测试](https://c.runoob.com/front-end/854)
>
> [菜鸟-正则表达式](https://www.runoob.com/?s=%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F&page=1)

