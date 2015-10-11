//
//  GSEnums.h
//  SipEndpoint
//
//  Created by Valery Polishchuk on 09/4/12.
//  Copyright (c) 2012 Genesys Labs. All rights reserved.
//



/**
 * A constant that defines the value for the SIP success code
 */
static const int GSSipSuccessCode = 200;

/**
 Defines possible endpoint states
 */
typedef enum GSEndpointState {
    GSEndpointInactiveState,
    GSEndpointActivatingState,
    GSEndpointActiveState,
    GSEndpointDeactivatingState
} GSEndpointState;

/**
 Defines possible connection states
 */
typedef enum GSConnectionState {
    GSConnectionUnregisteredState,
    GSConnectionRegisteringState,
    GSConnectionRegisteredState,
} GSConnectionState;

/**
 Defines possible connection states
 */
typedef enum GSSubscriptionState {
    GSSubscriptionUnsubscribedState,
    GSSubscriptionSubscribingState,
    GSSubscriptionSubscribedState,
} GSSubscriptionState;

/**
 Defines generic operation results
 */
typedef enum GSResult {
    GSResultOK,
    GSResultFailed,
    GSResultUnsupportedOperation,
    GSResultOperationInvalidForState,
    GSResultInvalidArgument,
    GSResultAlreadyInitialized
} GSResult;

/**
 Defines possible session states
 */
typedef enum GSSessionState {
    GSSessionStateAlerting,
    GSSessionStateConnected,
    GSSessionStateDisconnected,
    GSSessionStateInProgress,
    GSSessionStateUnknown,
    GSSessionStateHeld,
    GSSessionstateMediaOffer,
    GSSessionStateMediaAccepted
} GSSessionState;

/**
 Defines the possible routes a signal can take on an audio device
 */
typedef enum GSDeviceRoute {
    GSDeviceRouteDefault = 0,
    GSDeviceRouteEarpiece = 1,
    GSDeviceRouteSpeakerphone = 2,
    GSDeviceRouteBluetooth = 4
} GSDeviceRoute;

/**
 Defines the currently supported media types.
 */
typedef enum GSMediaType {
    GSMediaTypeAudio,
    GSMediaTypeVideo
} GSMediaType;

/**
 Defines the capabilities of an audio device.
 */
typedef enum GSAudioDeviceCapability {
    GSAudioDeviceCapabilityRouteToEarpiece,
    GSAudioDeviceCapabilityRouteToSpeakerPhone,
    GSAudioDeviceCapabilityRouteToBluetooth
} GSAudioDeviceCapability;

/**
 Defines the device array comparision type.
 */
typedef enum GSDeviceArrayComparisonType {
    GSDeviceArrayComparisonTypeRemovedDevices,
    GSDeviceArrayComparisonTypeAddedDevices
} GSDeviceArrayComparisonType;

/**
 Defines the video render format.
 */
typedef enum GSVideoRenderFormat {
    i420 = 0,
    YV12 = 1,
    YUY2 = 2,
    UYVY = 3,
    IYUV = 4,
    ARGB = 5,
    RGB24 = 6,
    RGB565 = 7,
    ARGB4444 = 8,
    ARGB1555 = 9,
    MJPEG = 10,
    NV12 = 11,
    NV21 = 12,
    BGRA = 13,
    Unknown = 99
} GSVideoRenderFormat;

/**
 Defines the status of operation.
 */
typedef enum GSStatus {
    GSStatusSuccess,
    GSSTATusAlreadyInitialized,
    GSStatusInvalidArg,
    GSSTatusCallNotConnectedToBridge, // OBSOLETE
    GSSTATusFailure,
    GSStatusDEviceBusy
} GSStatus;

/**
 Defines the video state.
 */
typedef enum GSVideoState {
    GSVideoStateInactive = 0,
    GSVideoStateActive,
    GSVideoStatePaused,
    GSVideoStateUnknown = -1
} GSVideoState;

/**
 Defines the currently supported DTMF methods.
 */
typedef enum GSDtmfMethod {
    GSDtmfMethodInbandRtp,
    GSDtmfMethodRfc2833,
    GSDtmfMethodInfo
} GSDtmfMethod;

typedef enum GSMediaStatisticType {
    GSMediaStatisticTypePacketsReceived,
    GSMediaStatisticTypePacketsLost,
    GSMediaStatisticTypePacketsDropped
} GSMediaStatisticType;

typedef enum GSFlagState {
    GSFlagStateFalse,
    GSFlagStateTrue,
    GSFlagStateUnknown = -1
} GSFlagState;

 