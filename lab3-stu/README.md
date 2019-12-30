# SystemVerilog LAB II

Please Use **VCS** to make the project.

## Introduction

- Makefile: file for make.
- make_class.mk: makefile子文件，完成面向对象编程的验证实现的编译（For exercise2）
- make_general.mk: make_file子文件，完成普通方式验证实现的make编译文件（For exercise1）
- src : 项目源代码文件
  - rtl : 功能模块RTL
  - tb  : System Verilog验证模块
    - tb-class: 面向对象编程源码(**Exercise 2**)
    - tb-general: 普通编程验证源码(**Exercise 1**)

## Build & Run

基于**VCS**，使用make完成编译和运行。

- `make run`: 编译所有并运行
- `make run_class`: 编译运行面向对象编程实现
- `make run_general`: 编译运行普通编程实现

编译并运行完成后，输出和波形文件在make目录下的 `build/log`文件夹下。

## Summary

By Sun Yongshuai

Any Questions:

- email: sunyongshui AT sjtu.edu.cn
- github: [https://github.com/SunicYosen/sv-course-labs/tree/master/lab2-stu](https://github.com/SunicYosen/sv-course-labs/tree/master/lab2-stu)
   





