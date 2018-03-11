#pragma once

#include <QtWidgets/QMainWindow>
#include "ui_QtGuiVisionPrj.h"
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/videoio.hpp> // for camera
using namespace cv;

class QtGuiVisionPrj : public QMainWindow
{
	Q_OBJECT

public:
	QtGuiVisionPrj(QWidget *parent = Q_NULLPTR);

private:
	Ui::QtGuiVisionPrjClass ui;
	QTimer *timer;
	Mat framewhite, frameblack;
	QImage imagewhite, imageblack;
	VideoCapture cap1, cap2;
	private slots:
	void opencam();
	void nextFrame();
	void closeCamara();
	void camshot();
	void Read_Data();
};
static QImage Mat2QImage(Mat& image);