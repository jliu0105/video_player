import QtQuick 2.9
import QtQuick.Window 2.2
//import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import com.imooc.myplayer 1.0

Window {
    id: root
    visible: true
    width: 800
    height: 600
    title: qsTr("MuYing Player")
    property bool fullscreen: false
    property bool isPlaying: myplay.isPlay
    property bool openSuccess: myplay.openSuccess
    property bool timeTrigger: false
    property string language:
    {
        root.title = qsTr("MuYing Player")
        chooseVideo.title = qsTr("Choose the video.")
        chooseVideo.nameFilters = [qsTr("Video files(*.mp4 *.rmvb *.flv)"),qsTr("All files(*)")]
        chooseSubtitle.title = qsTr("Choose the subtitle.")
        chooseSubtitle.nameFilters = [qsTr("Subtitle files(*.srt *.ssa *.ass)"),qsTr("All files(*)")]
        chooseSkin.title = qsTr("Choose the picture.")
        chooseSkin.nameFilters = [qsTr("Image files(*.png *.jpg *.bmp)"),qsTr("All files(*)")]
        languageDialog.title = qsTr("Language")
        chinese.text = qsTr("Chinese")
        english.text = qsTr("English")

        return MainApp.language
    }
    property int controlAreaHeight: 100
    property int subTitleTextHeight: 80
    property int controlAreaButtonWidth: 48
    property int controlAreaButtonHeight: 48
    property color controlAreaButtonPressedColor: "#265F99"
    property color controlAreaButtonUnpressedColor: "#00000000"
    property int controlAreaAutoHideInterval: 3000
    property int playPosUpdateInterval: 1000


    //键盘事件处理模块
    Item {
        id: keyEvent
        anchors.fill: parent
        Keys.enabled: true;
        focus:true
        Keys.onPressed: {
            if(event.key === Qt.Key_Space)
            {
                console.log("space pressed")
                myplay.playOrPause()
            }
            else if(event.key === Qt.Key_Escape)
            {
                console.log("escape pressed")
                if(fullscreen)
                {
                    fullscreen = false
                    visibility = 2                  //正常尺寸
                    root.width = root.width + 1     //刷新，防止卡屏
                }
            }
            else if(event.key === Qt.Key_Right)
            {
                console.log("right pressed")
                myplay.goOn()
            }
            else if(event.key === Qt.Key_Left)
            {
                console.log("left pressed")
                myplay.goBack()
            }
        }
    }

    //背景图片
    Image {
        id: backGround
        width: parent.width
        height: parent.height
        source: myplay.backGround ? "file:///" + myplay.backGround : ""
        //fillMode: Image.TileHorizontally
        smooth: true
    }

    MYPlay {
        id: myplay
        source: videooutput
    }
    MYVideoOutput {
        id: videooutput
        anchors.fill: parent
        visible: openSuccess?true:false
    }

    Text {
        id: subTitle
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: controlArea.visible ? controlArea.top : parent.bottom
        height: subTitleTextHeight
        text: myplay.subTitleText
        color: "#ff0000"
        font.pointSize: 24
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

//    Text {
//        id: text
//        anchors.fill: parent
//        text: "" + myplay.demoNum
//        color: "#ff0000"
//        font.pointSize: 50
//        verticalAlignment: Text.AlignVCenter
//        horizontalAlignment: Text.AlignHCenter
//    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: controlArea.top
        onDoubleClicked: {
            //console.log(visibility)
            //console.log("Double click")
            if(fullscreen)
            {
                fullscreen = false
                visibility = 2                  //正常尺寸
                root.width = root.width + 1     //刷新，防止卡屏
            }
            else
            {
                fullscreen = true
                visibility = 5                   //全屏显示
                root.width = Screen.width        //刷新，防止卡屏
            }
        }
    }

    MouseArea {
        anchors.fill: controlArea
        hoverEnabled: true
        onEntered: {
            // 鼠标进去控制区, 显示控制区, 关闭定时器
            controlArea.visible = true
            controlAreaHideTimer.stop()
        }
    }

    Item {
        id: controlArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.controlAreaHeight
        visible: false


        Rectangle {
            anchors.fill: parent
            color: "gray"
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                // 鼠标进去控制区, 关闭定时器
                controlAreaHideTimer.stop()
            }
            onExited: {
                // 鼠标离开控制区, 启动定时器, 时间到则隐藏控制区
                controlAreaHideTimer.start()
            }
        }

        // 播放进度条
        Slider {
            id: playPos
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 50
            anchors.rightMargin: 50
            anchors.topMargin: 10
            stepSize: 0.001
            onValueChanged: {
                //console.log(value);
                if(timeTrigger)
                {
                    timeTrigger = false
                    return
                }
                if(openSuccess && value >= 0.999)
                {
                    myplay.setStop()
                    value = 0
                    return
                }
                myplay.posFind(value)
            }
        }

        // 打开文件按钮
        Button {
            id: openFileBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.left: playPos.left
            anchors.leftMargin: 50
            anchors.top: playPos.bottom
            contentItem: Image {
                source: "qrc:///image/openFile.png"
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: openFileBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                chooseVideo.open();
            }
        }

        //打开视频文件框
        FileDialog {
            id: chooseVideo
            title: qsTr("Choose the video.")
            folder: myplay.videoPath ? "file:///" + myplay.videoPath : shortcuts.desktop     //默认路径桌面
            selectExisting: true
            selectFolder: false
            selectMultiple: false
            nameFilters: [qsTr("Video files(*.mp4 *.rmvb *.flv)"),qsTr("All files(*)")]
            onAccepted: {
                myplay.urlPass(chooseVideo.fileUrl.toString().substring(8,chooseVideo.fileUrl.length))
                myplay.changeVideoPath(chooseVideo.fileUrl.toString().substring(8,chooseVideo.fileUrl.length))
                if(root.isPlaying == true)
                    isPlayBtnImg.source = "qrc:///image/is_pause.png"
                console.log("You chose: " + chooseVideo.fileUrl.toString().substring(8,chooseVideo.fileUrl.length));
            }
            onRejected: {
                console.log("Canceled");
            }
        }

        // 更改语言按钮
        Button {
            id: changeLanguageBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.left: openFileBtn.right
            anchors.leftMargin: 10
            anchors.top: openFileBtn.top
            contentItem: Image {
                source: "qrc:///image/changeLanguage.png"
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: changeLanguageBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                myplay.testFunc()
                languageDialog.open()
            }
        }

        // 字幕按钮
        Button {
            id: subTitleBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.right: goBackBtn.left
            anchors.top: openFileBtn.top
            contentItem: Image {
                source: "qrc:///image/subTitle.png"
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: subTitleBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                chooseSubtitle.open();
            }
        }

        //打开字幕文件框
        FileDialog {
            id: chooseSubtitle
            title: qsTr("Choose the subtitle.")
            //folder: myplay.subTitlePath ? "file:///" + myplay.subTitlePath : shortcuts.desktop     //默认路径桌面
            folder: {
                if(!myplay.videoPath && !myplay.subTitlePath)
                {
                    return shortcuts.desktop
                }
                else if(!myplay.subTitlePath)
                {
                    return "file:///" + myplay.videoPath
                }
                else
                {
                    return "file:///" + myplay.subTitlePath
                }

            }
            selectExisting: true
            selectFolder: false
            selectMultiple: false
            nameFilters: [qsTr("Subtitle files(*.srt *.ssa *.ass)"),qsTr("All files(*)")]
            onAccepted: {
                console.log("You chose: " + chooseSubtitle.fileUrl);
                myplay.loadSubTitle(chooseSubtitle.fileUrl.toString().substring(8,chooseSubtitle.fileUrl.length))
                myplay.changeSubTitlePath(chooseSubtitle.fileUrl.toString().substring(8,chooseSubtitle.fileUrl.length))
            }
            onRejected: {
                console.log("Canceled");
            }
        }

        // 快退按钮
        Button {
            id: goBackBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.right: isPlayBtn.left
            anchors.top: openFileBtn.top
            contentItem: Image {
                source: "qrc:///image/goBack.png"
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: goBackBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                myplay.goBack()
            }
        }

        // 播放按钮
        Button {
            id: isPlayBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: openFileBtn.top
            contentItem: Image {
                id: isPlayBtnImg
                source: "qrc:///image/isPlay.png"
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: isPlayBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                myplay.playOrPause()
                if(root.isPlaying == true)
                    isPlayBtnImg.source = "qrc:///image/is_pause.png"
                else
                    isPlayBtnImg.source = "qrc:///image/isPlay.png"

            }
        }

        // 快进按钮
        Button {
            id: goOnBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.left: isPlayBtn.right
            anchors.top: openFileBtn.top
            contentItem: Image {
                width: parent.width
                height: parent.height
                source: "qrc:///image/goOn.png"
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: goOnBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                myplay.goOn()
            }
        }

        //停止按钮
        Button {
            id: isStopBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.left: goOnBtn.right
            anchors.top: openFileBtn.top
            contentItem: Image {
                width: parent.width
                height: parent.height
                source: "qrc:///image/isStop.png"
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: isStopBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                myplay.setStop()
                playPos.value = 0
            }
        }

        // 换肤按钮
        Button {
            id: changeSkinBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.left: isStopBtn.right
            anchors.top: openFileBtn.top
            contentItem: Image {
                width: parent.width
                height: parent.height
                source: "qrc:///image/changeSkin.png"
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: changeSkinBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                chooseSkin.open();
            }
        }

        //换肤文件框
        FileDialog {
            id: chooseSkin
            title: qsTr("Choose the picture.")
            folder: myplay.backGroundChoose ? "file:///" + myplay.backGroundChoose : shortcuts.desktop     //默认路径桌面
            selectExisting: true
            selectFolder: false
            selectMultiple: false
            nameFilters: [qsTr("Image files(*.png *.jpg *.bmp)"),qsTr("All files(*)")]
            onAccepted: {
                console.log(backGround.source)
                backGround.source = chooseSkin.fileUrl;
                myplay.changeBackground(chooseSkin.fileUrl.toString().substring(8,chooseSkin.fileUrl.length))
                console.log("You chose: " + chooseSkin.fileUrl);
            }
            onRejected: {
                console.log("Canceled");
            }
        }

        // 音量控制按钮
        Button {
            id: volumeBtn
            width: root.controlAreaButtonWidth
            height: root.controlAreaButtonHeight
            anchors.right: volumePos.left
            anchors.top: openFileBtn.top
            property double volume: 0.0
            contentItem: Image {
                id: volumeIcon
                width: parent.width
                height: parent.height
                source: {
                    if(volumePos.value >= 0.66)
                        return "qrc:///image/bigVoice.png"
                    else if(volumePos.value >= 0.33)
                        return "qrc:///image/midiumVoice.png"
                    else if(volumePos.value !== 0)
                        return "qrc:///image/smallVoice.png"
                    else if(volumePos.value === 0)
                        return "qrc:///image/zeroVoice.png"
                }
                fillMode: Image.PreserveAspectFit
            }
            background: Rectangle {
                implicitWidth: parent.width
                implicitHeight: parent.height
                color: volumeBtn.down ? root.controlAreaButtonPressedColor : root.controlAreaButtonUnpressedColor
                radius: 6
            }
            onClicked: {
                if(volumePos.value != 0)
                {
                    volume = volumePos.value;
                    volumePos.value = 0;
                }
                else
                {
                    volumePos.value = volume;
                }
            }
        }

        // 音量滑块
        Slider {
            id: volumePos
            anchors.right: playPos.right
            anchors.verticalCenter: openFileBtn.verticalCenter
            value: 1
            stepSize: 0.01
            width: 120
            onValueChanged:{
                console.log(value)
                if(value == 0 || value == 1)
                    myplay.change_volume(value)
            }
        }
    }

    //语言选择弹出框
    Dialog {
        id: languageDialog
        title: qsTr("Language")
        GroupBox{
            //title: qsTr("Language")
            ColumnLayout {
                //ExclusiveGroup {id: languageGroup}
                RadioButton {
                    id: chinese
                    text: qsTr("Chinese")
                    checked: language == "Chinese"?true:false
                    //ExclusiveGroup: languageGroup
                }
                RadioButton {
                    id: english
                    text: qsTr("English")
                    checked: language == "English"?true:false
                    //ExclusiveGroup: languageGroup
                }
            }
        }
        onAccepted: {
            switch(true){
                case chinese.checked:
                    console.log("chinese")
                    MainApp.changeLanuage("Chinese")
                    break;
                case english.checked:
                    console.log("english")
                    MainApp.changeLanuage("English")
                    break;
            }
        }

    }

    Timer {
        id: controlAreaHideTimer
        interval: root.controlAreaAutoHideInterval
        onTriggered: {
            controlArea.visible = false
        }
    }
    Timer {
        id: playPosUpdate
        interval: root.playPosUpdateInterval
        repeat: openSuccess?true:false
        running: openSuccess?true:false
        onTriggered: {
            timeTrigger = true
            playPos.value = myplay.posNum
        }
    }

}
