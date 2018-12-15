﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Environment
{
	public partial class MainForm : Form
	{
		List<PointF> keypoints = new List<PointF>();
		public MainForm()
		{
			InitializeComponent();
		}

		private void MapGenBtn_Click(object sender, EventArgs e)
		{

		}

		private void MainForm_Load(object sender, EventArgs e)
		{
			this.Rec_text.Text = "操作记录：\r\n";
			this.DrawSelect.SetItemCheckState(3, CheckState.Checked);//默认设置关键点
		}
		/// <summary>
		/// 单点
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void MapPictureBox_MouseDown(object sender, MouseEventArgs e)
		{
			if (this.DrawSelect.GetItemCheckState(4) == CheckState.Checked
				&& this.DrawSelect.GetItemCheckState(3) == CheckState.Unchecked)//删除关键点
			{
				PointF pf = new PointF(e.X, e.Y);
				int width = 10;
				int height = 10;
				List<int> delete_pt_idx = new List<int>();
				for (int i = 0; i < keypoints.Count; i++)
				{
					for (int x = (int)keypoints[i].X - Width; x < (int)keypoints[i].X + width; x++)
					{
						for (int y = (int)keypoints[i].Y - height; y < (int)keypoints[i].Y + height; y++)
						{
							if (x == e.X && y == e.Y)
							{
								delete_pt_idx.Add(i);
							}
						}
					}
				}
				//remove point and draw again
				if (delete_pt_idx.Count == 1)//一次删除一个点
				{
					PointF pfd = keypoints[delete_pt_idx[0]];
					keypoints.RemoveAt(delete_pt_idx[0]);

					Graphics g = this.MapPictureBox.CreateGraphics();
					Pen p = new Pen(Color.White, 1);
					//g.DrawRectangle(p, e.X - size / 2, e.Y - size / 2, size, size);
					Brush b = new SolidBrush(Color.White);
					int size = 4;
					g.FillRectangle(b, pfd.X - size / 2, pfd.Y - size / 2, size, size);
				}
				else if (delete_pt_idx.Count > 1)//附近有多个点
				{
					Form selectform = new Form();
					
				}
				else//没有点
				{
					//do nothing
				}
			}
			else if (this.DrawSelect.GetItemCheckState(3) == CheckState.Checked
				&& this.DrawSelect.GetItemCheckState(4) == CheckState.Unchecked)//设置关键点
			{
				int size = 4;
				PointF pt = new PointF(e.X, e.Y);
				keypoints.Add(pt);
				Graphics g = this.MapPictureBox.CreateGraphics();
				Pen p = new Pen(Color.Red, 1);
				//g.DrawRectangle(p, e.X - size / 2, e.Y - size / 2, size, size);
				Brush b = new SolidBrush(Color.Red);
				g.FillRectangle(b, e.X - size / 2, e.Y - size / 2, size, size);
				Rec_text.AppendText("坐标：" + e.X.ToString() + " " + e.Y.ToString() + "\r\n");
			}

		}

		private void MapPictureBox_Paint(object sender, PaintEventArgs e)
		{
			Graphics g = e.Graphics; //创建画板,这里的画板是由Form提供的.
			Pen p = new Pen(Color.Black, 1);//定义了一个蓝色,宽度为的画笔
											//g.DrawLine(p, 0, 0, this.Width, 0);//在画板上画直线,起始坐标为(10,10),终点坐标为(100,100)
			List<PointF> pts = new List<PointF>();
			pts.Add(new PointF(0, 0));
			pts.Add(new PointF(-MapPictureBox.Width, 0));
			pts.Add(new PointF(-MapPictureBox.Width, MapPictureBox.Height));
			int len = 1;//1个像素的边框大小
			g.DrawRectangle(p, 0, 0, MapPictureBox.Width - len, MapPictureBox.Height - len);
			Brush b = new SolidBrush(Color.White);
			g.FillRectangle(b, 0, 0, MapPictureBox.Width, MapPictureBox.Height);
			//g.DrawLines(p, pts.ToArray());
		}

		private void DrawSelect_ItemCheck(object sender, ItemCheckEventArgs e)
		{
			//this.DrawSelect.SetItemCheckState(e.Index, e.NewValue);
			if (e.Index == 4 && e.NewValue == CheckState.Checked)
			{
				this.DrawSelect.SetItemCheckState(3, CheckState.Unchecked);
			}
			if (e.Index == 3 && e.NewValue == CheckState.Checked)
			{
				this.DrawSelect.SetItemCheckState(4, CheckState.Unchecked);
			}
		}
	}
}
