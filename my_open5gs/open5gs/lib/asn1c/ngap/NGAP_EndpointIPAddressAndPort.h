/*
 * Generated by asn1c-0.9.29 (http://lionet.info/asn1c)
 * From ASN.1 module "NGAP-IEs"
 * 	found in "../support/ngap-r16.7.0/38413-g70.asn"
 * 	`asn1c -pdu=all -fcompound-names -findirect-choice -fno-include-deps -no-gen-BER -no-gen-XER -no-gen-OER -no-gen-UPER`
 */

#ifndef	_NGAP_EndpointIPAddressAndPort_H_
#define	_NGAP_EndpointIPAddressAndPort_H_


#include <asn_application.h>

/* Including external dependencies */
#include "NGAP_TransportLayerAddress.h"
#include "NGAP_PortNumber.h"
#include <constr_SEQUENCE.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Forward declarations */
struct NGAP_ProtocolExtensionContainer;

/* NGAP_EndpointIPAddressAndPort */
typedef struct NGAP_EndpointIPAddressAndPort {
	NGAP_TransportLayerAddress_t	 endpointIPAddress;
	NGAP_PortNumber_t	 portNumber;
	struct NGAP_ProtocolExtensionContainer	*iE_Extensions;	/* OPTIONAL */
	
	/* Context for parsing across buffer boundaries */
	asn_struct_ctx_t _asn_ctx;
} NGAP_EndpointIPAddressAndPort_t;

/* Implementation */
extern asn_TYPE_descriptor_t asn_DEF_NGAP_EndpointIPAddressAndPort;

#ifdef __cplusplus
}
#endif

#endif	/* _NGAP_EndpointIPAddressAndPort_H_ */
#include <asn_internal.h>
