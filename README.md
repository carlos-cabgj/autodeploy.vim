
# Autodeploy
This plugin have the finality to send your files to your destination server every time that you save your file.

You can use this plugin with Windows using plink and pscp or using python 3.

To use with python, make sure that you have python 3.* installed and in the patch in your pc

The plugin will work once that you have configured and installed with your own choice method, like:

###### vimplug
	call plug#begin('~/.vim/plugged')
	Plug 'skywind3000/asyncrun.vim'
	Plug 'carlos-cabgj/one-functions'
	Plug 'carlos-cabgj/autodeploy.vim'
	call plug#end()

[TOC]

#### Put in your .one-project this config ( thak will look like that ) 
###### Make shure that you have a .one-project in the root folder of your project
	{
		"autodeploy": {
			"status"     : 0,
			"program"    : 'PSCPPLINK',
			"type"       : "sftp",
			"host"       : "",
			"port"       : "22",
			"user"       : "",
			"pass"       : "",
			"pathServer" : "/u02/php/",
			"pathLocal"  : "/",
			"plink"      : 'c:\workspace\plink.exe',
			"pscp"       : 'c:\workspace\pscp.exe'
		}
	}

#### Configuration

- status : 0 to Off, 1 to On;
- program : PSCPPLINK or PYTHON3;
- type : Used in PSCPPLINK to describe ftp mode "Default sftp";
- host : Server Host;
- port : Server port;
- user : Server user;
- pass : Server password;
- pathServer : Path where the files will be deployed;
- pathLocal : Path to locate your files inside your project;
- plink : Path to plink binary, if using PSCPPLINK mode;
- pscp :  Path to pscp binary, if using PSCPPLINK mode;

