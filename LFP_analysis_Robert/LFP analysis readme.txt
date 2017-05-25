To test that this could run, I created a new folder and copied the .m files into it one at a time, then tried them on a file.  It seemed to run through, I didn’t try to optimize it for high vaf or anything.  These are the functions that ended up being included.

Actual analysis functions are located in the “fp analysis” folder:


buildLFPpositionDecoderRDF.m
example usage:
[vaf,H,bestf,bestc]=buildLFPpositionDecoderRDF(…pathtoBDFfile…);it’s designed to load in a file from disk but that of course could be changed.
This is the outermost function for doing basic LFP (or whatever signals are in the raw.analog field of the bdf) decoding analysis.  Should run with default values, if you want it to, but there are lots more things that can be passed in as well.  Check out the first several lines of code for examples.


fpAssignScript2.m  and fpAssignScript.m
both do the same job, under different circumstances.
——————as an aside, it is to my everlasting shame that I allowed this horrifically bad example of coding practice to perpetuate.  There is a script inside a function.  Yikes.—————————————


predictionsfromfp6.m
The workhorse function, does the FFTs, power calculations, and cross-validated decoder builing/evaluation.



FILMIMO3_tik.m, predMIMO3.m, filter22.m
old EJP functions, still hanging around.


rowBoat.m
stupid helper function, because I can never seem to remember whether things are row or column vectors


RcoeffDet.m  
calculates VAF, feel free to substitute you own favorite scoring function.



———————————————————————————————

.plx file “fragmentation issue”
This is what I was trying to explain during the meeting, when I talked about the plexon system occasionally dropping packets during acquisition.  I found a data file that exhibits the behavior: Chewie_Spike_LFP_11212011004.mat.  I’ve uploaded the file to the drive.  Check out the out_struct.raw.analog.ts, it has 11 time stamps per channel.  It does look like they’re the same for every channel, though I didn’t verify that exhaustively.  This file, which I re-processed after locating the issue, also has a field out_struct.raw.analog.fn, which together with the .ts field, allows you to figure out where the missing pieces are from the continuous data.  

code that pertains to the issue:

plx_ad.m should be in s1_analysis/bdf/lib_plx/core_files  
(but I copied it to here anyway)
Check out the help for the function, it basically explains everything.  This function is called by 

get_raw_plx.m which should be in s1_analysis/bdf/lib_plx  
This is the function I changed in order to get the .fn field into the output structure.  I believe I committed it to the SVN back in 2014 some time, so hopefully the version you guys migrated over to github had that already in it and there are no further changes that need to be made.

get_plexon_data.m is the function that calls get_raw_plx.m 
I did not modify this function, so I didn’t upload it to the google drive

fpAssignScript2.m handles this issue for my buildLFPpositionDecoderRDF.m function, if it finds a .fn field with more than 1 entry/channel.  Otherwise, it just assumes that the continuous acquisition went through the whole file without any dropped packets.  This script I uploaded, as mentioned above.


_______________________________________


I also uploaded 1 other data file, Chewie_Spike_LFP_09012011001.mat.  This file does not exhibit the dropped packets behavior, but it might be a better test file if you want something to run the code on to watch it go through its paces.  This was a hand-control file.  The other file I uploaded was a brain control file; as such calculating the VAF between its LFP data and its “kinematics” is a bit strange to interpret.


