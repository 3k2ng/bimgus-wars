level_1_data
	incbin "./data/level_1_data.zx02"
level_2_data
	incbin "./data/level_2_data.zx02"
level_data_table
	dc.w level_1_data
	dc.w level_2_data
	dc.w 0
