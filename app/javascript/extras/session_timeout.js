var dialog_notice = new BootstrapDialog({
    title: 'Session Timeout',
    message: 'You have been inactive and will be logged of in a few seconds'
});

//Function that checks if user has been inactive for too long
function check_session_limit(logout_url='/logout', logout_params={}){
    //convert session_limit form minutes to milliseconds
    idleWait = localStorage.session_limit*60*1000;
    localStorage.session_initialTime = localStorage.getItem('session_initialTime')||new Date()

    time_difference = (new Date()-new Date(localStorage.session_initialTime));
    if (time_difference>=idleWait  || !localStorage.getItem('session_active')){
        console.log('Logged out because user was inactive')
        location.href = logout_url+"?"+$.param(logout_params)
    }
}

//function for session timer
function session_timer(logout_url='/logout', logout_params={}){
    //Set initial time to countdown from
    localStorage.session_initialTime = new Date();
    //Notifications are done using jquery Dialog function
    //http://api.jqueryui.com/dialog/

    //Keep it closed until the end of the time limit
    dialog_notice.close();

    //start setInterval
    //https://www.w3schools.com/jsref/met_win_setinterval.asp
    setInterval(function(){
        check_session_limit(logout_url, logout_params)
        //Code for Dialog notification
        //Starts 10 seconds(10000ms) before logout
        if (time_difference>=(idleWait-(10000))){
            //Open Dialog
            //$("#inactive_session_notice").dialog('open')
            if (!dialog_notice.opened){
                dialog_notice.open()
                }

            //10 second countdown on Notification
            countdown = ((idleWait-time_difference)/1000).toFixed()
        }

        //Countdown on the console (optional)
        minutes_float = ((idleWait-time_difference)/1000/60)
        if (minutes_float>1){minutes = minutes_float.toFixed()}
        else{minutes = 0}
        seconds = ((idleWait-time_difference)/1000%60).toFixed()
        time_left = ('00'+minutes).slice(-2)+':'+('0'+seconds).slice(-2)
        localStorage.time_left = time_left
    //console.log(time_left)

    }, 1000);//this will run every 1 second(1000 milleseconds)
}