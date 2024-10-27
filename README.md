# moodecontrol

A new Flutter project.

# How to find the stream for a radio station on iHeartRadio? 


https://nz.api.iheart.com/api/v2/content/liveStations/9557

In the response there is list of URLs:

{
"streams": {
"hls_stream": "http://playerservices.streamtheworld.com/api/livestream-redirect/NZME_33AAC.m3u8",
"shoutcast_stream": "http://playerservices.streamtheworld.com/api/livestream-redirect/NZME_33AAC.aac",
"secure_hls_stream": "https://playerservices.streamtheworld.com/api/livestream-redirect/NZME_33AAC.m3u8",
"secure_shoutcast_stream": "https://playerservices.streamtheworld.com/api/livestream-redirect/NZME_33AAC.aac"
}
}