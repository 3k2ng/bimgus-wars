level_1_data
	incbin "./data/level_1_data.zx02"
level_2_data
	incbin "./data/level_2_data.zx02"
level_3_data
	incbin "./data/level_3_data.zx02"
level_4_data
	incbin "./data/level_4_data.zx02"
level_5_data
	incbin "./data/level_5_data.zx02"
level_data_table
	dc.w level_1_data
	dc.w level_2_data
	dc.w level_3_data
	dc.w level_4_data
	dc.w level_5_data
	dc.w 0
