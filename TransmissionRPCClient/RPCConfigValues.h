//
//  RPCConfigValues.h
//  TransmissionRPCClient
//
//  RPC config values using in JSON requests/answers
//

#ifndef TransmissionRPCClient_RPCConfigValues_h
#define TransmissionRPCClient_RPCConfigValues_h

// -- common rpc json values
#define TR_METHOD                                   @"method"
#define TR_METHOD_ARGS                              @"arguments"
#define TR_RETURNED_ARGS                            @"arguments"
#define TR_RESULT                                   @"result"
#define TR_RESULT_SUCCEED                           @"success"

#define TR_METHODNAME_TORRENTRESUME                 @"torrent-start"
#define TR_METHODNAME_TORRENTSTOP                   @"torrent-stop"
#define TR_METHODNAME_TORRENTREANNOUNCE             @"torrent-reannounce"
#define TR_METHODNAME_TORRENTVERIFY                 @"torrent-verify"

// ---- TORRENT GET --- arguments
#define TR_METHODNAME_TORRENTGET                    @"torrent-get"
#define TR_RETURNED_ARG_TORRENTS                    @"torrents"
#define TR_ARG_FIELDS                               @"fields"
#define TR_ARG_IDS                                  @"ids"
#define TR_ARG_FIELDS_ID                            @"id"
#define TR_ARG_FIELDS_NAME                          @"name"
#define TR_ARG_FIELDS_STATUS                        @"status"
// torrent statuses
#define TR_STATUS_STOPPED                           0 /* Torrent is stopped */
#define TR_STATUS_CHECK_WAIT                        1 /* Queued to check files */
#define TR_STATUS_CHECK                             2 /* Checking files */
#define TR_STATUS_DOWNLOAD_WAIT                     3 /* Queued to download */
#define TR_STATUS_DOWNLOAD                          4 /* Downloading */
#define TR_STATUS_SEED_WAIT                         5 /* Queued to seed */
#define TR_STATUS_SEED                              6 /* Seeding */
// -----
#define TR_ARG_FIELDS_PERCENTDONE                   @"percentDone"
#define TR_ARG_FIELDS_RATEDOWNLOAD                  @"rateDownload"
#define TR_ARG_FIELDS_RATEUPLOAD                    @"rateUpload"
#define TR_ARG_FIELDS_TOTALSIZE                     @"totalSize"
// peers
#define TR_ARG_FIELDS_PEERSCONNECTED                @"peersConnected"
#define TR_ARG_FIELDS_PEERSGETTINGFROMUS            @"peersGettingFromUs"
#define TR_ARG_FIELDS_PEERSSENDINGTOUS              @"peersSendingToUs"
//
#define TR_ARG_FIELDS_UPLOADEDEVER                  @"uploadedEver"
#define TR_ARG_FIELDS_UPLOADRATIO                   @"uploadRatio"

// ------ TORRENT GET ------
#define TR_ARG_FIELDS_COMMENT                       @"comment"
#define TR_ARG_FIELDS_CREATOR                       @"creator"
#define TR_ARG_FIELDS_DATECREATED                   @"dateCreated"
#define TR_ARG_FIELDS_ERRORNUM                      @"error"
#define TR_ARG_FIELDS_ERRORSTRING                   @"errorString"
#define TR_ARG_FIELDS_HASHSTRING                    @"hashString"
#define TR_ARG_FIELDS_DONEDATE                      @"doneDate"
#define TR_ARG_FIELDS_PIECECOUNT                    @"pieceCount"
#define TR_ARG_FIELDS_PIECESIZE                     @"pieceSize"
#define TR_ARG_FIELDS_SECONDSDOWNLOADING            @"secondsDownloading"
#define TR_ARG_FIELDS_SECONDSSEEDING                @"secondsSeeding"
#define TR_ARG_FIELDS_STARTDATE                     @"startDate"
#define TR_ARG_FIELDS_ACTIVITYDATE                  @"activityDate"
#define TR_ARG_FIELDS_HAVEVALID                     @"haveValid"
#define TR_ARG_FIELDS_HAVEUNCHECKED                 @"haveUnchecked"

#endif
