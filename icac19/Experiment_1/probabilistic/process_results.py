result_file = 'results.csv'

with open(result_file) as fp:
	for line in fp:
	
		content = line.split(',')
		num_cameras = int(content[0])
		max_interv = float(content[1])
		min_interv = float(content[2])
		states = float(content[3+4*num_cameras])
		
		dropped_max = 0
		dropped_min = 0
		sent_max = 0
		sent_min = 0
		
		for cam in range(num_cameras):
			dropped_max = dropped_max + float(content[3+cam+0*num_cameras])
			dropped_min = dropped_min + float(content[3+cam+1*num_cameras])
			sent_max = sent_max + float(content[3+cam+2*num_cameras])
			sent_min = sent_min + float(content[3+cam+3*num_cameras])
		
		cost = dropped_min * 10 + min_interv
		
		final_line = str(num_cameras) + ',' + str(max_interv) + ',' + \
			 str(min_interv) + ',' + str(dropped_max) + ',' + \
			 str(dropped_min) + ',' + str(sent_max) + ',' + \
			 str(sent_min) + ',' + str(cost) + ',' + str(states)
		
		print final_line

