level_1_data
	incbin "./data/level_1_data.zx02"
level_2_data
	incbin "./data/level_2_data.zx02"
level_data_table
	dc.w level_1_data, level_2_data, 0
