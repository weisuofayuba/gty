import QtQuick 2.0
import Qt.labs.particles 2.0
import "content/helpers.js" as Helpers

Rectangle{
    id: root
    width: 1200
    height: 1000
    color: "black"
    property bool spacePressed: false
    property int holeSize: 4
    focus: true
    Keys.onPressed: {
        if (event.key == Qt.Key_Space) {
            spacePressed = true;
            event.accepted = true;
        }
    }
    Keys.onReleased: {
        if (event.key == Qt.Key_Space) {
            spacePressed = false;
            event.accepted = true;
        }
    }

    Text{
        color: "white"
        font.pixelSize: 48
        anchors.centerIn: parent
        text: "GAME OVER"
        opacity: gameOver ? 1 : 0
        Behavior on opacity{NumberAnimation{}}
    }
    Text{
        color: "white"
        font.pixelSize: 24
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        text: "Score: " + score
    }
    property int score: 0
    property bool gameOver: false
    property int maxLives: 3
    property int lives: maxLives
    property bool alive: !Helpers.intersects(rocket, gs1.x, gs1.y, holeSize) && !Helpers.intersects(rocket, gs2.x, gs2.y, holeSize) && !Helpers.intersects(rocket, gs3.x, gs3.y, holeSize)  && !Helpers.intersects(rocket, gs4.x, gs4.y, holeSize);
    onAliveChanged: if(!alive){
        lives -= 1;
        if(lives == -1){
            console.log("game over");
            gameOver = true;
        }
    }
    Row{
        Repeater{
            model: maxLives
            delegate: Image{ 
                opacity: index < lives ? 1 : 0
                Behavior on opacity{NumberAnimation{}}
                source: "content/rocket.png" 
            }
        }
    }

    property real vorteX: width/4
    property real vorteY: height/4
    Behavior on vorteX{NumberAnimation{duration: 5000}}
    Behavior on vorteY{NumberAnimation{duration: 5000}}
    property real vorteX2: width/4
    property real vorteY2: 3*height/4
    Behavior on vorteX2{NumberAnimation{duration: 5000}}
    Behavior on vorteY2{NumberAnimation{duration: 5000}}
    property real vorteX3: 3*width/4
    property real vorteY3: height/4
    Behavior on vorteX3{NumberAnimation{duration: 5000}}
    Behavior on vorteY3{NumberAnimation{duration: 5000}}
    property real vorteX4: 3*width/4
    property real vorteY4: 3*height/4
    Behavior on vorteX4{NumberAnimation{duration: 5000}}
    Behavior on vorteY4{NumberAnimation{duration: 5000}}
    Timer{
        id: vorTimer
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            vorteX = Math.random() * width;
            vorteY = Math.random() * height;
            vorteX2 = Math.random() * width;
            vorteY2 = Math.random() * height;
            vorteX3 = Math.random() * width;
            vorteY3 = Math.random() * height;
            vorteX4 = Math.random() * width;
            vorteY4 = Math.random() * height;
        }
    }



    ParticleSystem{
        id: foreground
        anchors.fill: parent
        ColoredParticle{
            id: stars
            image: "content/star.png"
            color: "white"
            colorVariation: 0.1
            additive: 1
        }
        ColoredParticle{
            id: shot
            image: "content/star.png"

            color: "orange"
            colorVariation: 0.3
        }
        ColoredParticle{
            id: engine
            image: "content/particle4.png"

            color: "orange"
            SequentialAnimation on color {
                loops: Animation.Infinite
                ColorAnimation {
                    from: "red"
                    to: "cyan"
                    duration: 1000
                }
                ColorAnimation {
                    from: "cyan"
                    to: "red"
                    duration: 1000
                }
            }

            colorVariation: 0.2
            additive: 1
        }
        SpriteParticle{
            id: powerups
            Sprite{
                name: "norm"
                source: "content/powerupScore.png"
                frames: 35
                duration: 40
                to: {"norm":1, "got":0}
            }
            Sprite{
                name: "got"
                source: "content/powerupScore_got.png"
                frames: 22
                duration: 40
                to: {"null":1}
            }
            Sprite{
                name: "null"
                source: "content/powerupScore_gone.png"
                frames: 1
                duration: 1000
            }
        }
        affectors: [
            Zone{
                x: rocket.x - 30
                y: rocket.y - 30
                width: 60
                height: 60
                SpriteGoal{
                    goalState: "got"
                    jump: true
                    onAffected: if(!gameOver) score += 1000
                }
            }, GravitationalSingularity{
                id: gs1; x: vorteX; y: vorteY; strength: 800000;
            }, Zone{
                x: gs1.x - holeSize;
                y: gs1.y - holeSize;
                width: holeSize * 2
                height: holeSize * 2
                affector: Kill{}
            },
            GravitationalSingularity{
                id: gs2; x: vorteX2; y: vorteY2; strength: 800000;
            }, Zone{
                x: gs2.x - holeSize;
                y: gs2.y - holeSize;
                width: holeSize * 2
                height: holeSize * 2
                affector: Kill{}
            },
            GravitationalSingularity{
                id: gs3; x: vorteX3; y: vorteY3; strength: 800000;
            }, Zone{
                x: gs3.x - holeSize;
                y: gs3.y - holeSize;
                width: holeSize * 2
                height: holeSize * 2
                affector: Kill{}
            },
            GravitationalSingularity{
                id: gs4; x: vorteX4; y: vorteY4; strength: 800000;
            }, Zone{
                x: gs4.x - holeSize;
                y: gs4.y - holeSize;
                width: holeSize * 2
                height: holeSize * 2
                affector: Kill{}
            }        ]
    }
    TrailEmitter{
        particle: powerups
        system: foreground
        particlesPerSecond: 1
        particleDuration: 6000
        emitting: !gameOver
        particleSize: 60
        particleSizeVariation: 10
        anchors.fill: parent
    }
    TrailEmitter{
        particle: stars
        system: foreground
        particlesPerSecond: 40
        particleDuration: 4000
        emitting: !gameOver
        particleSize: 30
        particleSizeVariation: 10
        anchors.fill: parent
    }
    Image{
        id: rocket
        source:"content/rocket2.png"
        x: root.width/2
        y: root.height/2
        property int lx: 0
        property int ly: 0
        property int lastX: 0
        property int lastY: 0
        width: 45
        height: 22
        onXChanged:{ lastX = lx; lx = x;}
        onYChanged:{ lastY = ly; ly = y;}
        rotation: Helpers.direction(lastX, lastY, x, y)
        MouseArea{
            id: ma
            anchors.fill: parent;
            drag.axis: Drag.XandYAxis
            drag.target: rocket
        }
        TrailEmitter{
            system: foreground
            particle: engine
            particlesPerSecond: 100
            particleDuration: 1000
            emitting: !gameOver 
            particleSize: 10
            particleEndSize: 4
            particleSizeVariation: 4
            xSpeed: -128 * Math.cos(rocket.rotation * (Math.PI / 180))
            ySpeed: -128 * Math.sin(rocket.rotation * (Math.PI / 180))
            anchors.verticalCenter: parent.verticalCenter
            height: 4
            width: 4
            
        } 
        TrailEmitter{
            system: foreground
            particle: shot
            particlesPerSecond: 16
            particleDuration: 1600
            emitting: !gameOver
            particleSize: 40
            xSpeed: 128 * Math.cos(rocket.rotation * (Math.PI / 180))
            ySpeed: 128 * Math.sin(rocket.rotation * (Math.PI / 180))
            x: parent.width - 4
            y: parent.height/2
        }
    }
   ParticleSystem{
        id: background
        anchors.fill: parent
        particles: [ColoredParticle{
            id: stars2
            image: "content/star.png"
            color: "white"
            colorVariation: 0.1
            additive: 1
        }]
        emitters: [TrailEmitter{
            particle: stars2//TODO: Merge stars and roids
            particlesPerSecond: 60
            particleDuration: 4000
            emitting: true
            particleSize: 30
            particleSizeVariation: 10
            emitterX: root.width/2
            emitterY: root.height/2
            emitterXVariation: root.width/2
            emitterYVariation: root.height/2
        }]
    }
    Text{
        color: "white"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text:"Drag the ship, but don't hit a black hole!"
    }
}
