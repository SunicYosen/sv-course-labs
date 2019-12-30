# SystemVerilog LAB III

Please Use **VCS** to make the project.

## Introduction

- axi_lite/: axi实验子目录
  - makefile: makefile for vcs
  - vsrc: verilog和systemverilog的实现
  - build: build生成文件目录

- fifo/: FIFO实验子目录
  - makefile: makefile for vcs
  - vsrc: verilog和systemverilog的实现
  - build: build生成文件目录


## Build & Run

基于**VCS**，使用make完成编译和运行。

***FIFO***

- `cd fifo`
- `make run`: 编译所有并运行
- `make dve`: 查看波形图

***AXI***

- `cd axi_lite`
- `make run`: 编译所有并运行
- `make dve`: 查看波形图

编译并运行完成后，输出和波形文件在make目录下的 `build/log`文件夹下。

## Summary

By Sun Yongshuai

Any Questions:

- email: sunyongshui AT sjtu.edu.cn
- github: [https://github.com/SunicYosen/sv-course-labs/tree/master/lab3-stu](https://github.com/SunicYosen/sv-course-labs/tree/master/lab3-stu)
   





