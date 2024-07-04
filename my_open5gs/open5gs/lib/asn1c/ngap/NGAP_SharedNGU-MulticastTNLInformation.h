/*
 * Generated by asn1c-0.9.29 (http://lionet.info/asn1c)
 * From ASN.1 module "NGAP-IEs"
 * 	found in "../support/ngap-r17.3.0/38413-h30.asn"
 * 	`asn1c -pdu=all -fcompound-names -findirect-choice -fno-include-deps -no-gen-BER -no-gen-XER -no-gen-OER -no-gen-UPER`
 */

#ifndef	_NGAP_SharedNGU_MulticastTNLInformation_H_
#define	_NGAP_SharedNGU_MulticastTNLInformation_H_


#include <asn_application.h>

/* Including external dependencies */
#include "NGAP_TransportLayerAddress.h"
#include "NGAP_GTP-TEID.h"
#include <constr_SEQUENCE.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Forward declarations */
struct NGAP_ProtocolExtensionContainer;

/* NGAP_SharedNGU-MulticastTNLInformation */
typedef struct NGAP_SharedNGU_MulticastTNLInformation {
	NGAP_TransportLayerAddress_t	 iP_MulticastAddress;
	NGAP_TransportLayerAddress_t	 iP_SourceAddress;
	NGAP_GTP_TEID_t	 gTP_TEID;
	struct NGAP_ProtocolExtensionContainer	*iE_Extensions;	/* OPTIONAL */
	/*
	 * This type is extensible,
	 * possible extensions are below.
	 */
	
	/* Context for parsing across buffer boundaries */
	asn_struct_ctx_t _asn_ctx;
} NGAP_SharedNGU_MulticastTNLInformation_t;

/* Implementation */
extern asn_TYPE_descriptor_t asn_DEF_NGAP_SharedNGU_MulticastTNLInformation;
extern asn_SEQUENCE_specifics_t asn_SPC_NGAP_SharedNGU_MulticastTNLInformation_specs_1;
extern asn_TYPE_member_t asn_MBR_NGAP_SharedNGU_MulticastTNLInformation_1[4];

#ifdef __cplusplus
}
#endif

#endif	/* _NGAP_SharedNGU_MulticastTNLInformation_H_ */
#include <asn_internal.h>
