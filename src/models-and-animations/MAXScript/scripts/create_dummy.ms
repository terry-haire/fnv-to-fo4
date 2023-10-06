--create dummy
dummyObj = Dummy()
for i = 1 to namesArray.count do
(
	(getnodebyname namesArray[i]).parent dummyObj
)