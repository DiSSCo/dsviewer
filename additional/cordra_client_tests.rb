#https://zenodo.org/record/1487298 
#the png's are an example 
#Git Hub Repository fot user stories
#https://github.com/DiSSCo/user-stories 
#https://opendata.cines.fr/herbadrop-api/rest/data/search?P04450677
#https://opendata.cines.fr/herbadrop-api/rest/data/mnhn/P04450677
#https://opendata.cines.fr/herbadrop-api/rest/thumbnail/mnhnftp/P04450677/P04450677.jpg

require './lib/cordra_rest_client'


#get a list of DS
list_ds=CordraRestClient::DigitalObject.search("Digital Specimen",0, 10)

#get DS schema
result=CordraRestClient::DigitalObject.get_schema("DigitalSpecimen")
do_schema = JSON.parse(result.body)
# create a new class for the DS from the schema
do_properties = do_schema["properties"].keys
ds_class = CordraRestClient::DigitalObjectFactory.create_class "Digital Specimen".gsub(" ",""), do_properties 

#convert each of the results into a DS object and put it in a new array
ds_return=[] 
list_ds["results"].each do |ds|
  new_ds = ds_class.new 
  ds_data = ds["content"]
  CordraRestClient::DigitalObjectFactory.assing_attributes new_ds, ds_data
  ds_return.push(new_ds)
  ds_data.each do |field, arg|
    instance_var = field.gsub('/','_')
    instance_var = instance_var.gsub(' ','_')
    puts(field+": " + arg.to_s + " " + new_ds.instance_variable_get("@#{instance_var}").to_s)
  end
end
#end
do_schema["properties"].keys.each do |dsp|
  name = dsp
  type = do_schema["properties"][dsp]["type"]
  cordra_prev = "false"
  cordra_autogen = ""
  if do_schema["properties"][dsp].key?("cordra")
    if do_schema["properties"][dsp]["cordra"].key?("preview")
      cordra_prev = do_schema["properties"][dsp]["cordra"]["preview"]["showInPreview"].to_s
    end
    if do_schema["properties"][dsp]["cordra"].key?("type")
      cordra_autogen = do_schema["properties"][dsp]["cordra"]["type"]["autoGeneratedField"].to_s
    end
  end
  tp_min = ""
  tp_max = ""
  if do_schema["properties"][dsp].key?("minimum")
    tp_min = do_schema["properties"][dsp]["minimum"].to_s
  end
  if do_schema["properties"][dsp].key?("maximum")
    tp_max = do_schema["properties"][dsp]["maximum"].to_s
  end
  tp_maxlen = ""
  if do_schema["properties"][dsp].key?("maxLength")
    tp_maxlen = do_schema["properties"][dsp]["maxLength"].to_s
  end
  tp_title = ""
  if do_schema["properties"][dsp].key?("title")
    tp_title = do_schema["properties"][dsp]["title"].to_s
  end
  puts name +", "+ type + ", "+ cordra_prev + ", "+ cordra_autogen + ", "+ tp_min + ", "+ tp_max + ", "+ tp_maxlen + ", "+ tp_title
end

