### What does it take to summit Mt. Rainier?

This project analyzes the trends and statistics related with hikers' success and attempts in 2014 and 2015 at summitting Mt. Rainier in relation to the weather.  This project uses exploratory data analysis to try to investigate any trends and uses lasso and boosting models to predict success based off of weather data. 

### Using this repository 

This repository is best used with Docker. You can look at my Dockerfile to understand the necessary elements to be able to run the code that I have written. 

First you must close my git repository:

    git clone https://github.com/annikacleven/project611
    
Then you should change directories:

    cd project611

Note: I used the BIOS Virtual Machine.  If you are not on a BIOS Virtual Machine, things may not work exactly the same, but this has been tested to work on multiple BIOS VM's.  It should also be noted that when I getwd() I am in the "/home/rstudio" directory.  If you are not in this same directory things may not build correctly.  This should naturally be where you are, but if not then you may have to change into this directory. 


To begin run this following code into your terminal:

    docker build . -t project611
    
Then to run the docker container run this code: 

    docker run --rm -e USERID=$(id -u) -v $(pwd):/home/rstudio/work -v /home/users/arcleven/.ssh:/home/rstudio/.ssh -v ~/.git:/home/rstudio/.git -p 8787:8787 -it project611
    
Once the Rstudio is running connect to it by visiting <https://localhost:8787> in your browser.  Sign in using username: rstudio and the password provided (it should be a random string of letters and numbers)


### Building the Report

To build the final report follow these commands in the R Studio Terminal:

    cd work
    
To clean out all the targets that are built in this project use:

    make clean
    
To build the final report use:

    make MtRainierProject.html
    
You can create any of the individual targets that are used in the final report (and a few extra) by using the command `make` and then any of the targets listed in my Makefile.  

