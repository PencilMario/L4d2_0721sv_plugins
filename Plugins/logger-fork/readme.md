# Logger

> 修改自 [GlowingTree880](https://github.com/GlowingTree880/L4D2_LittlePlugins/tree/main/PlayerTeleport) 的Logger

- Logger 是一个日志头文件，提供了**面向对象的方法**用于记录日志，类似于 Java 语言中的 Slf4j 依赖
```java
import org.slf4j.LoggerFactory;

private static final Logger log = LoggerFactory.getLogger(getClass());
// 记录 info 级别日志
log.info("这是 info 级别的日志");
// 记录 error 级别日志
log.info("这是 error 级别的日志");
```
- 需要使用 Logger 的功能，首先需要在 .sp 文件中引入 Logger 头文件
```java
#include <Logger>
```
- 接着创建 Logger 的对象，不同于普通的 `methodmap`，由于 Logger 使用了 `__nullable__` 修饰，所以创建 Logger 时需要使用 `new` 关键字，参数填写Logger的名字
```java
Logger log = new Logger("Simple");
```
- 默认保存在`log/L********.log`，你也可以通过传入第二个参数来保存在一个新的log文件。如以下示例，log会被保存到`log/Simple.log`

```java
Logger log = new Logger("Simple", LoggerType_NewLogFile);
```

- 最后在 .sp 文件中就可以使用 Logger 对象来记录日志了
```java
log.info("这是 info 级别日志");
```
- 在 Logger 中，指定了 `debug`，`info` ，`warning`，`error`，`critical`，共五种日志级别，当然也可以自己定义。在`warning`及以上的级别，会额外输出到服务器控制台

- 你也可以使用`Logger.IgnoreLevel`来指定Logger对象的忽略级别，当log级别小于该级别时，将不会进行记录

- 你可以在`logger_test.sp`中查看它的用法，很简单