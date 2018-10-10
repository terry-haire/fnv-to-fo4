(
	fn isBox obj =
	(
		for i = 1 to obj.vertices.count do
			print obj.vertices[i].pos
	)
	isBox $
)