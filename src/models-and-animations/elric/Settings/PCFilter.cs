var eprocess = FilterScript.Result.Process;
var filePath = asFile.ToLower();
var filename = Path.GetFileName(filePath);

if(aeType == FileConverter.ConvertType.Mesh)
{
    if (filePath.Contains(".nif"))
    {
 		if(File.Exists(filePath.Replace(".nif", ".egm")) || filePath.Contains("facegendata"))
		{
			aMeshConverter.LogMessage(aLoggerID, InfoType.Info, "Turning off mesh optimization for Facegen file");
			aMeshConverter.OptimizeMeshes = false;
		}
		if(filename.Contains("head") || filePath.Contains("facegendata"))
		{
			aMeshConverter.ProcessAsHead = true;
		}
        if(filename.Contains("_facebones") && File.Exists(filePath.Replace("_facebones", "")))
            eprocess = FilterScript.Result.Skip; // these are exported with the non-facebones nif
    }
    else if(filePath.Contains("SwitchNodeChildren\\"))
        eprocess = FilterScript.Result.Skip; // these are combined into the switch node parent nif
}
else if(aeType == FileConverter.ConvertType.Texture)
{
    if(filePath.Contains(".tga") && File.Exists(filePath.Replace(".tga", ".dds").Replace("tgatextures", "ddstextures")))
    {
        aTextureConverter.LogMessage(aLoggerID, InfoType.Info, "DDS override: TGA not processed.");
        eprocess = FilterScript.Result.SkipAndCopy;
    }
    if(filePath.Contains("interface\\") && !filePath.Contains("interface\\objects\\"))
    {
        aTextureConverter.LogMessage(aLoggerID, InfoType.Info, "Turning off mipmap generation for interface texture.");
        aTextureConverter.GenerateMipMaps = false;
    }
    if(filePath.Contains(".dds"))
    {
        if(filePath.Contains("\\effects\\") || filePath.Contains("\\cubemaps\\") || filePath.Contains("\\tintmasks\\"))
	      eprocess = FilterScript.Result.SkipAndCopy;
    }
}

return eprocess;