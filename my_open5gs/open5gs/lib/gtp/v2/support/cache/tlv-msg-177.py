ies = []
ies.append({ "ie_type" : "Cause", "ie_value" : "Cause", "presence" : "M", "instance" : "0", "comment" : ""})
ies.append({ "ie_type" : "Delay Value", "ie_value" : "Data Notification Delay", "presence" : "C", "instance" : "0", "comment" : "he MME/SGSN shall include the delay the SGW shall apply between receiving downlink data and sending Downlink Data Notification for all UEs served by that MME/SGSN (see clause 5.3.4.2 of 3GPP TS 23.401 [3]), if the rate of Downlink Data Notification event occurrence in the MME/SGSN becomes significant (as configured by the operator) and the MME/SGSNs load exceeds an operator configured value.See NOTE 4."})
ies.append({ "ie_type" : "Recovery", "ie_value" : "Recovery", "presence" : "C", "instance" : "0", "comment" : "This IE shall be included if contacting the peer for the first time "})
ies.append({ "ie_type" : "Throttling", "ie_value" : "DL low priority traffic Throttling ", "presence" : "O", "instance" : "0", "comment" : "The MME/SGSN may send this IE to the SGW to request the SGW to reduce the number of Downlink Data Notification requests it sends for downlink low priority traffic received for UEs in idle mode served by that MME/SGSN in proportion to the Throttling Factor and during the Throttling Delay. See NOTE 1, NOTE 2, NOTE 3."})
ies.append({ "ie_type" : "IMSI", "ie_value" : "IMSI", "presence" : "CO", "instance" : "0", "comment" : "3GPP TS 23.007 [17] specifies conditions for sending this IE on the S11/S4 interface as part of the network triggered service restoration procedure, if both the SGW and the MME/S4-SGSN support this optional feature."})
ies.append({ "ie_type" : "EPC Timer", "ie_value" : "DL Buffering Duration", "presence" : "CO", "instance" : "0", "comment" : "The MME/SGSN shall include this IE on the S11/S4 interface to indicate the duration during which the SGW shall buffer DL data for this UE without sending any further Downlink Data Notification message, if extended buffering in the SGW is required: for a UE in a power saving state (e.g. Power Saving Mode or extended idle mode DRX) that cannot be reached by paging at the moment, as specified in clause 5.3.4.3 of 3GPP TS 23.401 [3], or.for a UE using NB-IoT, WB-EUTRAN or GERAN Extended Coverage with increased NAS transmission delay (see 3GPP TS 24.301 [23] and 3GPP TS 24.008 [5]).If this IE is included in the message, the Cause IE shall be set to Request Accepted."})
ies.append({ "ie_type" : "Integer Number", "ie_value" : "DL Buffering Suggested Packet Count", "presence" : "O", "instance" : "0", "comment" : "The MME/SGSN may include this IE on the S11/S4 interface, if the DL Buffering Duration IE is included, to suggest the maximum number of downlink data packets to be buffered in the SGW for this UE. "})
msg_list[key]["ies"] = ies
