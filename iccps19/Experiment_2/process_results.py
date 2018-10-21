result_file = 'results.csv'

with open(result_file) as fp:
	for line in fp:

		content = line.split(',')
		num_cameras = int(content[0])
		man_max_interv = float(content[1])
		man_min_interv = float(content[2])
		cam_max_interv = float(content[3])
		cam_min_interv = float(content[4])
		collab_max_interv = float(content[5])
		collab_min_interv = float(content[6])
		states = float(content[6+12*num_cameras])

		man_dropped_max = 0
		man_dropped_min = 0
		cam_dropped_max = 0
		cam_dropped_min = 0
		collab_dropped_max = 0
		collab_dropped_min = 0
		man_sent_max = 0
		man_sent_min = 0
		cam_sent_max = 0
		cam_sent_min = 0
		collab_sent_max = 0
		collab_sent_min = 0

		for cam in range(num_cameras):
			man_dropped_max = man_dropped_max + float(content[6+cam+0*num_cameras])
			man_dropped_min = man_dropped_min + float(content[6+cam+1*num_cameras])
			cam_dropped_max = cam_dropped_max + float(content[6+cam+2*num_cameras])
			cam_dropped_min = cam_dropped_min + float(content[6+cam+3*num_cameras])
			collab_dropped_max = collab_dropped_max + float(content[6+cam+4*num_cameras])
			collab_dropped_min = collab_dropped_min + float(content[6+cam+5*num_cameras])
			man_sent_max = man_sent_max + float(content[6+cam+6*num_cameras])
			man_sent_min = man_sent_min + float(content[6+cam+7*num_cameras])
			cam_sent_max = cam_sent_max + float(content[6+cam+8*num_cameras])
			cam_sent_min = cam_sent_min + float(content[6+cam+9*num_cameras])
			collab_sent_max = collab_sent_max + float(content[6+cam+10*num_cameras])
			collab_sent_min = collab_sent_min + float(content[6+cam+11*num_cameras])

		man_cost = man_dropped_min * 10 + man_min_interv
		cam_cost = cam_dropped_min * 10 + cam_min_interv
		collab_cost = collab_dropped_min * 10 + collab_min_interv

		final_line = str(num_cameras) + ',' + str(man_max_interv) + ',' + str(man_min_interv) + ',' + str(cam_max_interv) + ',' + str(cam_min_interv) + ',' + str(collab_max_interv) + ',' + str(collab_min_interv) + ',' +  str(man_dropped_max) +\
		',' + str(man_dropped_min) + ',' + str(cam_dropped_max) + ',' + str(cam_dropped_min) + ',' + str(collab_dropped_max) +\
		',' + str(collab_dropped_min) + ',' + str(man_sent_max) + ',' + str(man_sent_min) + ',' + str(cam_sent_max) + ',' + \
		str(cam_sent_min) + ',' + str(collab_sent_max) + ',' + str(collab_sent_min) + ',' + str(man_cost) + ',' + str(cam_cost) + ',' + str(collab_cost) + ',' + str(states)

		print final_line
