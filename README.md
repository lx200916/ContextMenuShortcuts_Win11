<div align="center">
  
# Context Menu Shortcuts Generator
</div>

###  说明
一个仿照Windows官方示例的Shell Extension, 用于添加自定义功能项到 Windows11 新样式右键菜单。大部分代码来自于 `strear`的[VSCode PR](https://github.com/strear/vscode/tree/40fa2790a739ae949aa9e3145a092465300d45ef/build/win32/shell-extension-win11).

注意，Win11的右键菜单项有以下限制:

* 应用必须含有一个 Identity,桌面应用通过 Sparse Package (一个仅包含AppxManifest声明的空MSIX包) 来获得 Identity.这也正是本项目生成的产物.
* 应用必须注册一个实现`IExplorerCommand`接口的DLL来响应右键菜单.
* Windows11 限制了一个应用只能创建一个一级菜单入口，并可以创建多个子菜单。本项目意在通过批量生成包的方式批量生成右键菜单捷径，因此每个包只添加一个一级菜单。如果你的使用场景是在一级菜单下创建多个子菜单，请考虑[ContextMenuForWindows11](https://github.com/ikas-mc/ContextMenuForWindows11)项目.
* 要侧载以上的 Sparse Package, 必须使用信任的根证书签发它.对于本项目而言，你需要信任 `./Release`文件夹下的 `Key.cer`并添加到`受信任的根证书存储区`.当然你也可以自行签发信任证书并覆盖此文件. 

效果如下:

![image](https://user-images.githubusercontent.com/44310445/174622439-ba5c8560-d9d5-442d-b80c-eb7694fbf077.png)

### 使用方法
为避免安装庞大的`Windows SDK`, 本项目采用Github Actions来完成产物编译.

请在Fork本项目后,进行如下修改.
1. 修改 `settings.json`.
```
`icon`: 右键菜单项的图标,可采用绝对路径指定(请使用运行时目标系统上的绝对路径并保证文件存在).
`title`： 右键菜单项显示名称.
`cmd`:点击右键菜单时执行的命令. %1 参数为选定文件/文件夹/当前文件夹(当在空白处右键点击)的绝对路径.
`name`: 生成包的名称
```
2. 启用 Actions, 并提交触发Actions.
3. 下载编译产物.
4. 信任 `Key.cer`
5. 安装Appx并添加DLL路径,在Appx路径下执行: 注意，以下代码注册了此路径为Appx包依赖的一部分，因此会被Appx包占用，无法修改和删除其中内容.
```
$releasePath = (resolve-path .)
Add-AppxPackage ${releasePath}\apex-sparse.appx -ExternalLocation ${releasePath}
```
