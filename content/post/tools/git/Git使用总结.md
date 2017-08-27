---
title: "Git使用总结"
date: 2016-08-11T20:36:00+08:00
tags: ["git"]
categories: ["tools"]
---
# 远程分支
* 项目开发，需要使用版本控制器，来控制开发流程，一般有一台公用服务器用于存放远程分支

<!--more-->

* 假设远程分支如下所示
    ```
    A-->B-->C-->D-->E-->G(HEAD||master)
                \-->F-->H(asshole_branch)
    
    ```
* 这里有两个分支，一个是master分支，另一个则是asshole_branch分支，HEAD指代的是远程分支的默认分支，即远程仓库中当前所处的分支
* **git init**:如果现在在服务器上，想直接自己建个仓库，比如在~/wuyinjie/myproject/greatfighter目录下建一个仓库，那么直接切换到这个目录下，并且打开git bash，输入git init即可创建一个仓库

# 本地分支
* **git clone**:本机上现在什么都没有，需要从远程分支上clone分支下来，使用git clone url指令将远程分支clone到本地，注意，这里的url是一个地址，例如git@oa.ejoy.com/afc.git，clone以后，本地分支的表现形式为：
    ```
    A-->B-->C-->D-->E-->G(origin/HEAD||origin/master||master)
                \-->F-->H(origin/asshole_branch)
    
    ```
* 在本地分支中，origin是clone后默认生成的，表示远程分支的标志，意味着上一次更新远程分支的状态，master则是当前的主干分支，本地HEAD指针目前指向master节点
* **git status**:这个指令用来查看git目前的状态，会将unstage，stage，commit的信息输出
* **git add**：我们在本地，新建一个文件，或者修改一个文件的时候，这个文件就是unstage状态的文件，unstage状态的文件是不能直接commit的，需要通过git add指令来将这些文件标记为stage状态
* **git commit**：文件暂存起来以后，就能进行提交了，通过git commit -m comment的方式，将信息提交，比如在此过程中，我提交了三次，那么节点会变为
    ```
    A-->B-->C-->D-->E-->G(origin/HEAD||origin/master||)-->I-->J-->K(master)
                \-->F-->H(origin/asshole_branch)
    
    ```
    如果此时远程分支有人提交了两次，生成L，M节点那么远程分支就变为
    ```
    A-->B-->C-->D-->E-->G-->L-->M(HEAD||master)
                \-->F-->H(origin/asshole_branch)
    
    ```
* **git stash save**:更新前要保持本地分支干净，因此先进行statsh save操作，将本地所有的改动放到一个stack中
* **git fetch**:从远程更新代码，可以用git pull指令，或者是git fetch指令，使用git pull指令，最后会将本地改动和远程改动全部merge到一个节点中，这样会导致项目线条非常复杂，而且所有的改动合并到一个节点内也不容易被回滚，因此这里主场使用fetch指令，fetch指令，会将远程分支考到本地，因为本地也有一个远程分支的索引，因此fetch以后，会改变本地的远程分支分布情况
    ```
    A-->B-->C-->D-->E-->G-->I-->J-->K(HEAD||master)
                \       \-->L-->M(origin/HEAD||origin/master)
                \-->F-->H(origin/asshole_branch)
    
    ```
    * 用法
        * git fetch             直接把远程分支更新到本地
        * git fetch origin branch_name  将远程指定分支更新到本地
* **git rebase**：因为git fetch只是把远程分支更新到本地，并不作任何处理，因此更新好以后，像上面举的例子那样，现在本地有三个分支分别是master，远程分支和asshole_branch分支，我们更新的数据都在本地的远程分支上，因此需要合并两个分支使用git rebase指令更好，例如git rebase origin/master，因为此时是在master分支上，因此这段指令是直接拿本地分支和本地远程分支合并，最后得到的结果是
    ```
    A-->B-->C-->D-->E-->G-->L-->M
                \               \-->I'-->J'-->K'
                \-->F-->H(origin/asshole_branch)
    
    ```
    这里，I先和M合并一次，得到I',然后J再和I'合并得到J',再和K合并得到K'，此时K'变成origin/master,origin/head,HEAD,master于一身的节点
* **git push**：push要先进行更新合并，到这一步，直接调用git push就能把节点分布同步到远程分支上
* **git stash pop**:分支合并完，就可以将原来stash save起来的数据，再弹出来
* **git reset**：回滚专用，如果想将代码上次改为上个commit的状态，直接调git reset HEAD，那么此时本地所有改动添加都会被撤销掉，想要重置回远程节点的状态，只需要git reset origin/branch_name即可
* git reset HEAD：撤销所有的添加和改动，还原到和最新一次commit的节点一致
* git reset hash_key:直接撤销到指定commit节点
* git reset --soft HEAD：回滚到本地HEAD，但是修改/添加的数据不清理
* git reset --hard HEAD：回滚到本地HEAD，但是清理修改，新增的数据

# 分支操作
* git branch：罗列本地分支
* git branch -a:查看所有分支
* git branch -r：查看远程分支
* git branch -b branch_name：新建一个叫做branch_name的分支
* git checkout branch_name：切到对应分支
* git checkout -b branch_name：新建一个分支，并切到该分支

# 查看所有提交记录：
git log

# 撤销
* 有时候不小心commit了东西，但是没有push的前提下，还是可以撤销的，使用git reset --soft HEAD^指令，可以撤销刚刚进行的commit，--soft的意思撤销提交但是保留修改
* 某个文件要撤销stage状态，只需使用git reset HEAD filename

# 与github设置关联
要使得本地git仓库和github通过ssh进行通信，需要生成一个public key和private key，这里有两种方式
1. 使用TotoiseGit的PuTTYGen工具，生成一个public key和一个包含私钥的.ppk文件，然后在TotoiseGit设置界面，指定.ppk文件的路径，这样就可以使用TotoiseGit工具，就能从github上clone仓库，fetch更新，push commit等
2. 还有一种方式，则是通过secureCRT工具，生成一个.pub文件的公钥和一个私钥文件，此时只需要将两个名字改名为id_rsa即可，并且将两个文件拷贝到git安装目录的.ssh文件夹下，同时在github上add新增加的ssh public key，这样就能和github进行交互了

# 参考文献
* http://gogojimmy.net/2012/01/17/how-to-use-git-1-git-basic/
* http://blog.gogojimmy.net/2012/01/21/how-to-use-git-2-basic-usage-and-worflow/
* http://blog.gogojimmy.net/2012/02/29/git-scenario/
* https://git-scm.com/docs/git-fetch
* http://www.ruanyifeng.com/blog/2014/06/git_remote.html