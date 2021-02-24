$(document).ready(function() {
    // Preparing sounds
    var stallAlert = new Audio("./sounds/stall.mp3");
    var altitudeAlert = new Audio("./sounds/altitude.mp3");
    var missileAlert = new Audio("./sounds/missile.mp3");

    // Appending steps in degrees and current direction
    for (let i = 0; i < 3; i ++) {
        $(".direction").append(`<div class="single-direction bold">N</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">NE</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">E</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">SE</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">S</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">SW</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">W</div>`);
        separateDirections();
        $(".direction").append(`<div class="single-direction bold">NW</div>`);
        separateDirections();
    }

    // Separate letters
    function separateDirections() {
        for (let i = 0; i < 3; i++) {
            $(".direction").append(`<div class="single-direction">&nbsp;</div>`);
        }
    }

    // Append horizontal Pitch lines
    for (let i = 18; i > 0; i--) {
        $(".pitch").append(`
        <div class="pitchline">
            <div class="leftline">
                <div class="pitch-number">
                    ${i * 5}
                </div>
                <div class="line"></div>
            </div>
            <div class="rightline">
                <div class="line"></div>
                <div class="pitch-number">
                    ${i * 5}
                </div>
            </div>
        </div>
        `)
    }
    $(".pitch").append(`
        <div class="pitchline">
            <div class="leftline">
                <div class="pitch-number">
                    ${0}
                </div>
                <div class="line full"></div>
            </div>
            <div class="rightline">
                <div class="line full"></div>
                <div class="pitch-number">
                    ${0}
                </div>
            </div>
        </div>
    `)
    for (let i = 1; i <= 18; i++) {
        $(".pitch").append(`
        <div class="pitchline">
            <div class="leftline">
                <div class="pitch-number">
                    ${i * -5}
                </div>
                <div class="linedown"></div>
            </div>
            <div class="rightline">
                <div class="linedown"></div>
                <div class="pitch-number">
                    ${i * -5}
                </div>
            </div>
        </div>
        `)
    }

    // Handle HUD movement
    function ChangeYaw(value) {
        let deg = value;
        let px = (deg * 2.22) - 273;
        $(".direction").css("left", `${px}px`);
        $("#heading-text").text(deg);
    }
    ChangeYaw(0);

    function ChangeRoll(value) {
        let deg = value * -1;
        let contr = value;
        $(".pitchroll").css("transform", `translate(-50%, -50%) rotate(${deg}deg)`);
        $(".pitch-number").css("transform", `rotate(${contr}deg)`);
    }
    ChangeRoll(0);

    function ChangePitch(value) {
        let deg = value;
        let px = (deg * 13.65) - 1115;
        $(".pitch").css("margin-top", `${px}px`);
    }
    ChangePitch(0);

    window.addEventListener('message', function (event) {
        if (event.data.action == "show") {
            $("#main").fadeIn();
            $("#main").removeClass("red");
            $("#main").removeClass("orange");
            $("#main").removeClass("green");
            $("#main").removeClass("blue");
            $("#main").addClass(event.data.color);
        }
        if (event.data.action == "hide") {
            $("#main").fadeOut();
        }
        if (event.data.action == "update") {
            $("#speed").text(event.data.speed);
            $("#alt").text(event.data.altitude);
            let alt = event.data.rawAlt;
            alt = (285 - ((alt / 2400) * 285));
            $(".altitude-pointer").css("margin-top", `${alt}px`);
            if (event.data.gear == "STATIC") {
                $(".gear-info").hide();
            } else {
                $(".gear-info").show();
                $("#gear-state").text(event.data.gear);
            }
            if (event.data.hasWeapon == true) {
                if (event.data.weaponType == "missiles") {
                    $(".gun-crosshair").hide();
                    $(".missile-info").show();
                    if (event.data.hasLock == false) {
                        $(".missile-target").hide();
                        $(".missile-dist").hide();
                    } else {
                        $(".missile-target").show();
                        $(".missile-dist").show();
                        $(".missile-dist").text(event.data.targetDist);
                    }
                    $(".missile-info").css("left", `${event.data.x_target * 100}%`);
                    $(".missile-info").css("top", `${event.data.y_target * 100}%`);
                } else if (event.data.weaponType == "machinegun") {
                    $(".missile-info").hide();
                    $(".gun-crosshair").show();
                    $(".gun-crosshair").css("left", `${event.data.x_target * 100}%`);
                    $(".gun-crosshair").css("top", `${event.data.y_target * 100}%`);
                }
            } else {
                $(".missile-info").hide();
                $(".gun-crosshair").hide();
            }
            if (event.data.hasVtol == false) {
                $(".vtol-info").hide();
            } else {
                $(".vtol-info").show();
                $("#vtol-state").text(event.data.vtol);
            }
            ChangeYaw(event.data.yaw);
            ChangeRoll(event.data.roll);
            ChangePitch(event.data.pitch);
        }
        if (event.data.action == "stall") {
            if (event.data.mode == "start") {
                stallAlert.play();
                stallAlert.loop = true;
                $(".stall-warn").show();
            } else if (event.data.mode == "end") {
                stallAlert.pause();
                stallAlert.currentTime = 0;
                $(".stall-warn").hide();
            }
        }
        if (event.data.action == "altitude") {
            if (event.data.mode == "start") {
                altitudeAlert.play();
                altitudeAlert.loop = true;
                $(".alt-warn").show();
            } else if (event.data.mode == "end") {
                altitudeAlert.pause();
                altitudeAlert.currentTime = 0;
                $(".alt-warn").hide();
            }
        }
        if (event.data.action == "missile") {
            if (event.data.mode == "start") {
                missileAlert.play();
                missileAlert.loop = true;
                $(".missile-warn").show();
            } else if (event.data.mode == "end") {
                missileAlert.pause();
                missileAlert.currentTime = 0;
                $(".missile-warn").hide();
            }
        }
    });
});