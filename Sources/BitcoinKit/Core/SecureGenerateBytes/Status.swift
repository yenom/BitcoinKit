//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

// swiftlint:disable all

// Copied from: https://github.com/kishikawakatsumi/KeychainAccess/blob/master/Lib/KeychainAccess/Keychain.swift
public enum Status: OSStatus, Error {
    case success                            = 0
    case unimplemented                      = -4
    case diskFull                           = -34
    case io                                 = -36
    case opWr                               = -49
    case param                              = -50
    case wrPerm                             = -61
    case allocate                           = -108
    case userCanceled                       = -128
    case badReq                             = -909
    case internalComponent                  = -2070
    case notAvailable                       = -25291
    case readOnly                           = -25292
    case authFailed                         = -25293
    case noSuchKeychain                     = -25294
    case invalidKeychain                    = -25295
    case duplicateKeychain                  = -25296
    case duplicateCallback                  = -25297
    case invalidCallback                    = -25298
    case duplicateItem                      = -25299
    case itemNotFound                       = -25300
    case bufferTooSmall                     = -25301
    case dataTooLarge                       = -25302
    case noSuchAttr                         = -25303
    case invalidItemRef                     = -25304
    case invalidSearchRef                   = -25305
    case noSuchClass                        = -25306
    case noDefaultKeychain                  = -25307
    case interactionNotAllowed              = -25308
    case readOnlyAttr                       = -25309
    case wrongSecVersion                    = -25310
    case keySizeNotAllowed                  = -25311
    case noStorageModule                    = -25312
    case noCertificateModule                = -25313
    case noPolicyModule                     = -25314
    case interactionRequired                = -25315
    case dataNotAvailable                   = -25316
    case dataNotModifiable                  = -25317
    case createChainFailed                  = -25318
    case invalidPrefsDomain                 = -25319
    case inDarkWake                         = -25320
    case aclNotSimple                       = -25240
    case policyNotFound                     = -25241
    case invalidTrustSetting                = -25242
    case noAccessForItem                    = -25243
    case invalidOwnerEdit                   = -25244
    case trustNotAvailable                  = -25245
    case unsupportedFormat                  = -25256
    case unknownFormat                      = -25257
    case keyIsSensitive                     = -25258
    case multiplePrivKeys                   = -25259
    case passphraseRequired                 = -25260
    case invalidPasswordRef                 = -25261
    case invalidTrustSettings               = -25262
    case noTrustSettings                    = -25263
    case pkcs12VerifyFailure                = -25264
    case invalidCertificate                 = -26265
    case notSigner                          = -26267
    case policyDenied                       = -26270
    case invalidKey                         = -26274
    case decode                             = -26275
    case `internal`                         = -26276
    case unsupportedAlgorithm               = -26268
    case unsupportedOperation               = -26271
    case unsupportedPadding                 = -26273
    case itemInvalidKey                     = -34000
    case itemInvalidKeyType                 = -34001
    case itemInvalidValue                   = -34002
    case itemClassMissing                   = -34003
    case itemMatchUnsupported               = -34004
    case useItemListUnsupported             = -34005
    case useKeychainUnsupported             = -34006
    case useKeychainListUnsupported         = -34007
    case returnDataUnsupported              = -34008
    case returnAttributesUnsupported        = -34009
    case returnRefUnsupported               = -34010
    case returnPersitentRefUnsupported      = -34011
    case valueRefUnsupported                = -34012
    case valuePersistentRefUnsupported      = -34013
    case returnMissingPointer               = -34014
    case matchLimitUnsupported              = -34015
    case itemIllegalQuery                   = -34016
    case waitForCallback                    = -34017
    case missingEntitlement                 = -34018
    case upgradePending                     = -34019
    case mpSignatureInvalid                 = -25327
    case otrTooOld                          = -25328
    case otrIDTooNew                        = -25329
    case serviceNotAvailable                = -67585
    case insufficientClientID               = -67586
    case deviceReset                        = -67587
    case deviceFailed                       = -67588
    case appleAddAppACLSubject              = -67589
    case applePublicKeyIncomplete           = -67590
    case appleSignatureMismatch             = -67591
    case appleInvalidKeyStartDate           = -67592
    case appleInvalidKeyEndDate             = -67593
    case conversionError                    = -67594
    case appleSSLv2Rollback                 = -67595
    case quotaExceeded                      = -67596
    case fileTooBig                         = -67597
    case invalidDatabaseBlob                = -67598
    case invalidKeyBlob                     = -67599
    case incompatibleDatabaseBlob           = -67600
    case incompatibleKeyBlob                = -67601
    case hostNameMismatch                   = -67602
    case unknownCriticalExtensionFlag       = -67603
    case noBasicConstraints                 = -67604
    case noBasicConstraintsCA               = -67605
    case invalidAuthorityKeyID              = -67606
    case invalidSubjectKeyID                = -67607
    case invalidKeyUsageForPolicy           = -67608
    case invalidExtendedKeyUsage            = -67609
    case invalidIDLinkage                   = -67610
    case pathLengthConstraintExceeded       = -67611
    case invalidRoot                        = -67612
    case crlExpired                         = -67613
    case crlNotValidYet                     = -67614
    case crlNotFound                        = -67615
    case crlServerDown                      = -67616
    case crlBadURI                          = -67617
    case unknownCertExtension               = -67618
    case unknownCRLExtension                = -67619
    case crlNotTrusted                      = -67620
    case crlPolicyFailed                    = -67621
    case idpFailure                         = -67622
    case smimeEmailAddressesNotFound        = -67623
    case smimeBadExtendedKeyUsage           = -67624
    case smimeBadKeyUsage                   = -67625
    case smimeKeyUsageNotCritical           = -67626
    case smimeNoEmailAddress                = -67627
    case smimeSubjAltNameNotCritical        = -67628
    case sslBadExtendedKeyUsage             = -67629
    case ocspBadResponse                    = -67630
    case ocspBadRequest                     = -67631
    case ocspUnavailable                    = -67632
    case ocspStatusUnrecognized             = -67633
    case endOfData                          = -67634
    case incompleteCertRevocationCheck      = -67635
    case networkFailure                     = -67636
    case ocspNotTrustedToAnchor             = -67637
    case recordModified                     = -67638
    case ocspSignatureError                 = -67639
    case ocspNoSigner                       = -67640
    case ocspResponderMalformedReq          = -67641
    case ocspResponderInternalError         = -67642
    case ocspResponderTryLater              = -67643
    case ocspResponderSignatureRequired     = -67644
    case ocspResponderUnauthorized          = -67645
    case ocspResponseNonceMismatch          = -67646
    case codeSigningBadCertChainLength      = -67647
    case codeSigningNoBasicConstraints      = -67648
    case codeSigningBadPathLengthConstraint = -67649
    case codeSigningNoExtendedKeyUsage      = -67650
    case codeSigningDevelopment             = -67651
    case resourceSignBadCertChainLength     = -67652
    case resourceSignBadExtKeyUsage         = -67653
    case trustSettingDeny                   = -67654
    case invalidSubjectName                 = -67655
    case unknownQualifiedCertStatement      = -67656
    case mobileMeRequestQueued              = -67657
    case mobileMeRequestRedirected          = -67658
    case mobileMeServerError                = -67659
    case mobileMeServerNotAvailable         = -67660
    case mobileMeServerAlreadyExists        = -67661
    case mobileMeServerServiceErr           = -67662
    case mobileMeRequestAlreadyPending      = -67663
    case mobileMeNoRequestPending           = -67664
    case mobileMeCSRVerifyFailure           = -67665
    case mobileMeFailedConsistencyCheck     = -67666
    case notInitialized                     = -67667
    case invalidHandleUsage                 = -67668
    case pvcReferentNotFound                = -67669
    case functionIntegrityFail              = -67670
    case internalError                      = -67671
    case memoryError                        = -67672
    case invalidData                        = -67673
    case mdsError                           = -67674
    case invalidPointer                     = -67675
    case selfCheckFailed                    = -67676
    case functionFailed                     = -67677
    case moduleManifestVerifyFailed         = -67678
    case invalidGUID                        = -67679
    case invalidHandle                      = -67680
    case invalidDBList                      = -67681
    case invalidPassthroughID               = -67682
    case invalidNetworkAddress              = -67683
    case crlAlreadySigned                   = -67684
    case invalidNumberOfFields              = -67685
    case verificationFailure                = -67686
    case unknownTag                         = -67687
    case invalidSignature                   = -67688
    case invalidName                        = -67689
    case invalidCertificateRef              = -67690
    case invalidCertificateGroup            = -67691
    case tagNotFound                        = -67692
    case invalidQuery                       = -67693
    case invalidValue                       = -67694
    case callbackFailed                     = -67695
    case aclDeleteFailed                    = -67696
    case aclReplaceFailed                   = -67697
    case aclAddFailed                       = -67698
    case aclChangeFailed                    = -67699
    case invalidAccessCredentials           = -67700
    case invalidRecord                      = -67701
    case invalidACL                         = -67702
    case invalidSampleValue                 = -67703
    case incompatibleVersion                = -67704
    case privilegeNotGranted                = -67705
    case invalidScope                       = -67706
    case pvcAlreadyConfigured               = -67707
    case invalidPVC                         = -67708
    case emmLoadFailed                      = -67709
    case emmUnloadFailed                    = -67710
    case addinLoadFailed                    = -67711
    case invalidKeyRef                      = -67712
    case invalidKeyHierarchy                = -67713
    case addinUnloadFailed                  = -67714
    case libraryReferenceNotFound           = -67715
    case invalidAddinFunctionTable          = -67716
    case invalidServiceMask                 = -67717
    case moduleNotLoaded                    = -67718
    case invalidSubServiceID                = -67719
    case attributeNotInContext              = -67720
    case moduleManagerInitializeFailed      = -67721
    case moduleManagerNotFound              = -67722
    case eventNotificationCallbackNotFound  = -67723
    case inputLengthError                   = -67724
    case outputLengthError                  = -67725
    case privilegeNotSupported              = -67726
    case deviceError                        = -67727
    case attachHandleBusy                   = -67728
    case notLoggedIn                        = -67729
    case algorithmMismatch                  = -67730
    case keyUsageIncorrect                  = -67731
    case keyBlobTypeIncorrect               = -67732
    case keyHeaderInconsistent              = -67733
    case unsupportedKeyFormat               = -67734
    case unsupportedKeySize                 = -67735
    case invalidKeyUsageMask                = -67736
    case unsupportedKeyUsageMask            = -67737
    case invalidKeyAttributeMask            = -67738
    case unsupportedKeyAttributeMask        = -67739
    case invalidKeyLabel                    = -67740
    case unsupportedKeyLabel                = -67741
    case invalidKeyFormat                   = -67742
    case unsupportedVectorOfBuffers         = -67743
    case invalidInputVector                 = -67744
    case invalidOutputVector                = -67745
    case invalidContext                     = -67746
    case invalidAlgorithm                   = -67747
    case invalidAttributeKey                = -67748
    case missingAttributeKey                = -67749
    case invalidAttributeInitVector         = -67750
    case missingAttributeInitVector         = -67751
    case invalidAttributeSalt               = -67752
    case missingAttributeSalt               = -67753
    case invalidAttributePadding            = -67754
    case missingAttributePadding            = -67755
    case invalidAttributeRandom             = -67756
    case missingAttributeRandom             = -67757
    case invalidAttributeSeed               = -67758
    case missingAttributeSeed               = -67759
    case invalidAttributePassphrase         = -67760
    case missingAttributePassphrase         = -67761
    case invalidAttributeKeyLength          = -67762
    case missingAttributeKeyLength          = -67763
    case invalidAttributeBlockSize          = -67764
    case missingAttributeBlockSize          = -67765
    case invalidAttributeOutputSize         = -67766
    case missingAttributeOutputSize         = -67767
    case invalidAttributeRounds             = -67768
    case missingAttributeRounds             = -67769
    case invalidAlgorithmParms              = -67770
    case missingAlgorithmParms              = -67771
    case invalidAttributeLabel              = -67772
    case missingAttributeLabel              = -67773
    case invalidAttributeKeyType            = -67774
    case missingAttributeKeyType            = -67775
    case invalidAttributeMode               = -67776
    case missingAttributeMode               = -67777
    case invalidAttributeEffectiveBits      = -67778
    case missingAttributeEffectiveBits      = -67779
    case invalidAttributeStartDate          = -67780
    case missingAttributeStartDate          = -67781
    case invalidAttributeEndDate            = -67782
    case missingAttributeEndDate            = -67783
    case invalidAttributeVersion            = -67784
    case missingAttributeVersion            = -67785
    case invalidAttributePrime              = -67786
    case missingAttributePrime              = -67787
    case invalidAttributeBase               = -67788
    case missingAttributeBase               = -67789
    case invalidAttributeSubprime           = -67790
    case missingAttributeSubprime           = -67791
    case invalidAttributeIterationCount     = -67792
    case missingAttributeIterationCount     = -67793
    case invalidAttributeDLDBHandle         = -67794
    case missingAttributeDLDBHandle         = -67795
    case invalidAttributeAccessCredentials  = -67796
    case missingAttributeAccessCredentials  = -67797
    case invalidAttributePublicKeyFormat    = -67798
    case missingAttributePublicKeyFormat    = -67799
    case invalidAttributePrivateKeyFormat   = -67800
    case missingAttributePrivateKeyFormat   = -67801
    case invalidAttributeSymmetricKeyFormat = -67802
    case missingAttributeSymmetricKeyFormat = -67803
    case invalidAttributeWrappedKeyFormat   = -67804
    case missingAttributeWrappedKeyFormat   = -67805
    case stagedOperationInProgress          = -67806
    case stagedOperationNotStarted          = -67807
    case verifyFailed                       = -67808
    case querySizeUnknown                   = -67809
    case blockSizeMismatch                  = -67810
    case publicKeyInconsistent              = -67811
    case deviceVerifyFailed                 = -67812
    case invalidLoginName                   = -67813
    case alreadyLoggedIn                    = -67814
    case invalidDigestAlgorithm             = -67815
    case invalidCRLGroup                    = -67816
    case certificateCannotOperate           = -67817
    case certificateExpired                 = -67818
    case certificateNotValidYet             = -67819
    case certificateRevoked                 = -67820
    case certificateSuspended               = -67821
    case insufficientCredentials            = -67822
    case invalidAction                      = -67823
    case invalidAuthority                   = -67824
    case verifyActionFailed                 = -67825
    case invalidCertAuthority               = -67826
    case invaldCRLAuthority                 = -67827
    case invalidCRLEncoding                 = -67828
    case invalidCRLType                     = -67829
    case invalidCRL                         = -67830
    case invalidFormType                    = -67831
    case invalidID                          = -67832
    case invalidIdentifier                  = -67833
    case invalidIndex                       = -67834
    case invalidPolicyIdentifiers           = -67835
    case invalidTimeString                  = -67836
    case invalidReason                      = -67837
    case invalidRequestInputs               = -67838
    case invalidResponseVector              = -67839
    case invalidStopOnPolicy                = -67840
    case invalidTuple                       = -67841
    case multipleValuesUnsupported          = -67842
    case notTrusted                         = -67843
    case noDefaultAuthority                 = -67844
    case rejectedForm                       = -67845
    case requestLost                        = -67846
    case requestRejected                    = -67847
    case unsupportedAddressType             = -67848
    case unsupportedService                 = -67849
    case invalidTupleGroup                  = -67850
    case invalidBaseACLs                    = -67851
    case invalidTupleCredendtials           = -67852
    case invalidEncoding                    = -67853
    case invalidValidityPeriod              = -67854
    case invalidRequestor                   = -67855
    case requestDescriptor                  = -67856
    case invalidBundleInfo                  = -67857
    case invalidCRLIndex                    = -67858
    case noFieldValues                      = -67859
    case unsupportedFieldFormat             = -67860
    case unsupportedIndexInfo               = -67861
    case unsupportedLocality                = -67862
    case unsupportedNumAttributes           = -67863
    case unsupportedNumIndexes              = -67864
    case unsupportedNumRecordTypes          = -67865
    case fieldSpecifiedMultiple             = -67866
    case incompatibleFieldFormat            = -67867
    case invalidParsingModule               = -67868
    case databaseLocked                     = -67869
    case datastoreIsOpen                    = -67870
    case missingValue                       = -67871
    case unsupportedQueryLimits             = -67872
    case unsupportedNumSelectionPreds       = -67873
    case unsupportedOperator                = -67874
    case invalidDBLocation                  = -67875
    case invalidAccessRequest               = -67876
    case invalidIndexInfo                   = -67877
    case invalidNewOwner                    = -67878
    case invalidModifyMode                  = -67879
    case missingRequiredExtension           = -67880
    case extendedKeyUsageNotCritical        = -67881
    case timestampMissing                   = -67882
    case timestampInvalid                   = -67883
    case timestampNotTrusted                = -67884
    case timestampServiceNotAvailable       = -67885
    case timestampBadAlg                    = -67886
    case timestampBadRequest                = -67887
    case timestampBadDataFormat             = -67888
    case timestampTimeNotAvailable          = -67889
    case timestampUnacceptedPolicy          = -67890
    case timestampUnacceptedExtension       = -67891
    case timestampAddInfoNotAvailable       = -67892
    case timestampSystemFailure             = -67893
    case signingTimeMissing                 = -67894
    case timestampRejection                 = -67895
    case timestampWaiting                   = -67896
    case timestampRevocationWarning         = -67897
    case timestampRevocationNotification    = -67898
    case unexpectedError                    = -99999
}

extension Status: RawRepresentable, CustomStringConvertible {
    
    public init(status: OSStatus) {
        if let mappedStatus = Status(rawValue: status) {
            self = mappedStatus
        } else {
            self = .unexpectedError
        }
    }
    
    public var description: String {
        switch self {
        case .success:
            return "No error."
        case .unimplemented:
            return "Function or operation not implemented."
        case .diskFull:
            return "The disk is full."
        case .io:
            return "I/O error (bummers)"
        case .opWr:
            return "file already open with with write permission"
        case .param:
            return "One or more parameters passed to a function were not valid."
        case .wrPerm:
            return "write permissions error"
        case .allocate:
            return "Failed to allocate memory."
        case .userCanceled:
            return "User canceled the operation."
        case .badReq:
            return "Bad parameter or invalid state for operation."
        case .internalComponent:
            return ""
        case .notAvailable:
            return "No keychain is available. You may need to restart your computer."
        case .readOnly:
            return "This keychain cannot be modified."
        case .authFailed:
            return "The user name or passphrase you entered is not correct."
        case .noSuchKeychain:
            return "The specified keychain could not be found."
        case .invalidKeychain:
            return "The specified keychain is not a valid keychain file."
        case .duplicateKeychain:
            return "A keychain with the same name already exists."
        case .duplicateCallback:
            return "The specified callback function is already installed."
        case .invalidCallback:
            return "The specified callback function is not valid."
        case .duplicateItem:
            return "The specified item already exists in the keychain."
        case .itemNotFound:
            return "The specified item could not be found in the keychain."
        case .bufferTooSmall:
            return "There is not enough memory available to use the specified item."
        case .dataTooLarge:
            return "This item contains information which is too large or in a format that cannot be displayed."
        case .noSuchAttr:
            return "The specified attribute does not exist."
        case .invalidItemRef:
            return "The specified item is no longer valid. It may have been deleted from the keychain."
        case .invalidSearchRef:
            return "Unable to search the current keychain."
        case .noSuchClass:
            return "The specified item does not appear to be a valid keychain item."
        case .noDefaultKeychain:
            return "A default keychain could not be found."
        case .interactionNotAllowed:
            return "User interaction is not allowed."
        case .readOnlyAttr:
            return "The specified attribute could not be modified."
        case .wrongSecVersion:
            return "This keychain was created by a different version of the system software and cannot be opened."
        case .keySizeNotAllowed:
            return "This item specifies a key size which is too large."
        case .noStorageModule:
            return "A required component (data storage module) could not be loaded. You may need to restart your computer."
        case .noCertificateModule:
            return "A required component (certificate module) could not be loaded. You may need to restart your computer."
        case .noPolicyModule:
            return "A required component (policy module) could not be loaded. You may need to restart your computer."
        case .interactionRequired:
            return "User interaction is required, but is currently not allowed."
        case .dataNotAvailable:
            return "The contents of this item cannot be retrieved."
        case .dataNotModifiable:
            return "The contents of this item cannot be modified."
        case .createChainFailed:
            return "One or more certificates required to validate this certificate cannot be found."
        case .invalidPrefsDomain:
            return "The specified preferences domain is not valid."
        case .inDarkWake:
            return "In dark wake, no UI possible"
        case .aclNotSimple:
            return "The specified access control list is not in standard (simple) form."
        case .policyNotFound:
            return "The specified policy cannot be found."
        case .invalidTrustSetting:
            return "The specified trust setting is invalid."
        case .noAccessForItem:
            return "The specified item has no access control."
        case .invalidOwnerEdit:
            return "Invalid attempt to change the owner of this item."
        case .trustNotAvailable:
            return "No trust results are available."
        case .unsupportedFormat:
            return "Import/Export format unsupported."
        case .unknownFormat:
            return "Unknown format in import."
        case .keyIsSensitive:
            return "Key material must be wrapped for export."
        case .multiplePrivKeys:
            return "An attempt was made to import multiple private keys."
        case .passphraseRequired:
            return "Passphrase is required for import/export."
        case .invalidPasswordRef:
            return "The password reference was invalid."
        case .invalidTrustSettings:
            return "The Trust Settings Record was corrupted."
        case .noTrustSettings:
            return "No Trust Settings were found."
        case .pkcs12VerifyFailure:
            return "MAC verification failed during PKCS12 import (wrong password?)"
        case .invalidCertificate:
            return "This certificate could not be decoded."
        case .notSigner:
            return "A certificate was not signed by its proposed parent."
        case .policyDenied:
            return "The certificate chain was not trusted due to a policy not accepting it."
        case .invalidKey:
            return "The provided key material was not valid."
        case .decode:
            return "Unable to decode the provided data."
        case .`internal`:
            return "An internal error occurred in the Security framework."
        case .unsupportedAlgorithm:
            return "An unsupported algorithm was encountered."
        case .unsupportedOperation:
            return "The operation you requested is not supported by this key."
        case .unsupportedPadding:
            return "The padding you requested is not supported."
        case .itemInvalidKey:
            return "A string key in dictionary is not one of the supported keys."
        case .itemInvalidKeyType:
            return "A key in a dictionary is neither a CFStringRef nor a CFNumberRef."
        case .itemInvalidValue:
            return "A value in a dictionary is an invalid (or unsupported) CF type."
        case .itemClassMissing:
            return "No kSecItemClass key was specified in a dictionary."
        case .itemMatchUnsupported:
            return "The caller passed one or more kSecMatch keys to a function which does not support matches."
        case .useItemListUnsupported:
            return "The caller passed in a kSecUseItemList key to a function which does not support it."
        case .useKeychainUnsupported:
            return "The caller passed in a kSecUseKeychain key to a function which does not support it."
        case .useKeychainListUnsupported:
            return "The caller passed in a kSecUseKeychainList key to a function which does not support it."
        case .returnDataUnsupported:
            return "The caller passed in a kSecReturnData key to a function which does not support it."
        case .returnAttributesUnsupported:
            return "The caller passed in a kSecReturnAttributes key to a function which does not support it."
        case .returnRefUnsupported:
            return "The caller passed in a kSecReturnRef key to a function which does not support it."
        case .returnPersitentRefUnsupported:
            return "The caller passed in a kSecReturnPersistentRef key to a function which does not support it."
        case .valueRefUnsupported:
            return "The caller passed in a kSecValueRef key to a function which does not support it."
        case .valuePersistentRefUnsupported:
            return "The caller passed in a kSecValuePersistentRef key to a function which does not support it."
        case .returnMissingPointer:
            return "The caller passed asked for something to be returned but did not pass in a result pointer."
        case .matchLimitUnsupported:
            return "The caller passed in a kSecMatchLimit key to a call which does not support limits."
        case .itemIllegalQuery:
            return "The caller passed in a query which contained too many keys."
        case .waitForCallback:
            return "This operation is incomplete, until the callback is invoked (not an error)."
        case .missingEntitlement:
            return "Internal error when a required entitlement isn't present, client has neither application-identifier nor keychain-access-groups entitlements."
        case .upgradePending:
            return "Error returned if keychain database needs a schema migration but the device is locked, clients should wait for a device unlock notification and retry the command."
        case .mpSignatureInvalid:
            return "Signature invalid on MP message"
        case .otrTooOld:
            return "Message is too old to use"
        case .otrIDTooNew:
            return "Key ID is too new to use! Message from the future?"
        case .serviceNotAvailable:
            return "The required service is not available."
        case .insufficientClientID:
            return "The client ID is not correct."
        case .deviceReset:
            return "A device reset has occurred."
        case .deviceFailed:
            return "A device failure has occurred."
        case .appleAddAppACLSubject:
            return "Adding an application ACL subject failed."
        case .applePublicKeyIncomplete:
            return "The public key is incomplete."
        case .appleSignatureMismatch:
            return "A signature mismatch has occurred."
        case .appleInvalidKeyStartDate:
            return "The specified key has an invalid start date."
        case .appleInvalidKeyEndDate:
            return "The specified key has an invalid end date."
        case .conversionError:
            return "A conversion error has occurred."
        case .appleSSLv2Rollback:
            return "A SSLv2 rollback error has occurred."
        case .quotaExceeded:
            return "The quota was exceeded."
        case .fileTooBig:
            return "The file is too big."
        case .invalidDatabaseBlob:
            return "The specified database has an invalid blob."
        case .invalidKeyBlob:
            return "The specified database has an invalid key blob."
        case .incompatibleDatabaseBlob:
            return "The specified database has an incompatible blob."
        case .incompatibleKeyBlob:
            return "The specified database has an incompatible key blob."
        case .hostNameMismatch:
            return "A host name mismatch has occurred."
        case .unknownCriticalExtensionFlag:
            return "There is an unknown critical extension flag."
        case .noBasicConstraints:
            return "No basic constraints were found."
        case .noBasicConstraintsCA:
            return "No basic CA constraints were found."
        case .invalidAuthorityKeyID:
            return "The authority key ID is not valid."
        case .invalidSubjectKeyID:
            return "The subject key ID is not valid."
        case .invalidKeyUsageForPolicy:
            return "The key usage is not valid for the specified policy."
        case .invalidExtendedKeyUsage:
            return "The extended key usage is not valid."
        case .invalidIDLinkage:
            return "The ID linkage is not valid."
        case .pathLengthConstraintExceeded:
            return "The path length constraint was exceeded."
        case .invalidRoot:
            return "The root or anchor certificate is not valid."
        case .crlExpired:
            return "The CRL has expired."
        case .crlNotValidYet:
            return "The CRL is not yet valid."
        case .crlNotFound:
            return "The CRL was not found."
        case .crlServerDown:
            return "The CRL server is down."
        case .crlBadURI:
            return "The CRL has a bad Uniform Resource Identifier."
        case .unknownCertExtension:
            return "An unknown certificate extension was encountered."
        case .unknownCRLExtension:
            return "An unknown CRL extension was encountered."
        case .crlNotTrusted:
            return "The CRL is not trusted."
        case .crlPolicyFailed:
            return "The CRL policy failed."
        case .idpFailure:
            return "The issuing distribution point was not valid."
        case .smimeEmailAddressesNotFound:
            return "An email address mismatch was encountered."
        case .smimeBadExtendedKeyUsage:
            return "The appropriate extended key usage for SMIME was not found."
        case .smimeBadKeyUsage:
            return "The key usage is not compatible with SMIME."
        case .smimeKeyUsageNotCritical:
            return "The key usage extension is not marked as critical."
        case .smimeNoEmailAddress:
            return "No email address was found in the certificate."
        case .smimeSubjAltNameNotCritical:
            return "The subject alternative name extension is not marked as critical."
        case .sslBadExtendedKeyUsage:
            return "The appropriate extended key usage for SSL was not found."
        case .ocspBadResponse:
            return "The OCSP response was incorrect or could not be parsed."
        case .ocspBadRequest:
            return "The OCSP request was incorrect or could not be parsed."
        case .ocspUnavailable:
            return "OCSP service is unavailable."
        case .ocspStatusUnrecognized:
            return "The OCSP server did not recognize this certificate."
        case .endOfData:
            return "An end-of-data was detected."
        case .incompleteCertRevocationCheck:
            return "An incomplete certificate revocation check occurred."
        case .networkFailure:
            return "A network failure occurred."
        case .ocspNotTrustedToAnchor:
            return "The OCSP response was not trusted to a root or anchor certificate."
        case .recordModified:
            return "The record was modified."
        case .ocspSignatureError:
            return "The OCSP response had an invalid signature."
        case .ocspNoSigner:
            return "The OCSP response had no signer."
        case .ocspResponderMalformedReq:
            return "The OCSP responder was given a malformed request."
        case .ocspResponderInternalError:
            return "The OCSP responder encountered an internal error."
        case .ocspResponderTryLater:
            return "The OCSP responder is busy, try again later."
        case .ocspResponderSignatureRequired:
            return "The OCSP responder requires a signature."
        case .ocspResponderUnauthorized:
            return "The OCSP responder rejected this request as unauthorized."
        case .ocspResponseNonceMismatch:
            return "The OCSP response nonce did not match the request."
        case .codeSigningBadCertChainLength:
            return "Code signing encountered an incorrect certificate chain length."
        case .codeSigningNoBasicConstraints:
            return "Code signing found no basic constraints."
        case .codeSigningBadPathLengthConstraint:
            return "Code signing encountered an incorrect path length constraint."
        case .codeSigningNoExtendedKeyUsage:
            return "Code signing found no extended key usage."
        case .codeSigningDevelopment:
            return "Code signing indicated use of a development-only certificate."
        case .resourceSignBadCertChainLength:
            return "Resource signing has encountered an incorrect certificate chain length."
        case .resourceSignBadExtKeyUsage:
            return "Resource signing has encountered an error in the extended key usage."
        case .trustSettingDeny:
            return "The trust setting for this policy was set to Deny."
        case .invalidSubjectName:
            return "An invalid certificate subject name was encountered."
        case .unknownQualifiedCertStatement:
            return "An unknown qualified certificate statement was encountered."
        case .mobileMeRequestQueued:
            return "The MobileMe request will be sent during the next connection."
        case .mobileMeRequestRedirected:
            return "The MobileMe request was redirected."
        case .mobileMeServerError:
            return "A MobileMe server error occurred."
        case .mobileMeServerNotAvailable:
            return "The MobileMe server is not available."
        case .mobileMeServerAlreadyExists:
            return "The MobileMe server reported that the item already exists."
        case .mobileMeServerServiceErr:
            return "A MobileMe service error has occurred."
        case .mobileMeRequestAlreadyPending:
            return "A MobileMe request is already pending."
        case .mobileMeNoRequestPending:
            return "MobileMe has no request pending."
        case .mobileMeCSRVerifyFailure:
            return "A MobileMe CSR verification failure has occurred."
        case .mobileMeFailedConsistencyCheck:
            return "MobileMe has found a failed consistency check."
        case .notInitialized:
            return "A function was called without initializing CSSM."
        case .invalidHandleUsage:
            return "The CSSM handle does not match with the service type."
        case .pvcReferentNotFound:
            return "A reference to the calling module was not found in the list of authorized callers."
        case .functionIntegrityFail:
            return "A function address was not within the verified module."
        case .internalError:
            return "An internal error has occurred."
        case .memoryError:
            return "A memory error has occurred."
        case .invalidData:
            return "Invalid data was encountered."
        case .mdsError:
            return "A Module Directory Service error has occurred."
        case .invalidPointer:
            return "An invalid pointer was encountered."
        case .selfCheckFailed:
            return "Self-check has failed."
        case .functionFailed:
            return "A function has failed."
        case .moduleManifestVerifyFailed:
            return "A module manifest verification failure has occurred."
        case .invalidGUID:
            return "An invalid GUID was encountered."
        case .invalidHandle:
            return "An invalid handle was encountered."
        case .invalidDBList:
            return "An invalid DB list was encountered."
        case .invalidPassthroughID:
            return "An invalid passthrough ID was encountered."
        case .invalidNetworkAddress:
            return "An invalid network address was encountered."
        case .crlAlreadySigned:
            return "The certificate revocation list is already signed."
        case .invalidNumberOfFields:
            return "An invalid number of fields were encountered."
        case .verificationFailure:
            return "A verification failure occurred."
        case .unknownTag:
            return "An unknown tag was encountered."
        case .invalidSignature:
            return "An invalid signature was encountered."
        case .invalidName:
            return "An invalid name was encountered."
        case .invalidCertificateRef:
            return "An invalid certificate reference was encountered."
        case .invalidCertificateGroup:
            return "An invalid certificate group was encountered."
        case .tagNotFound:
            return "The specified tag was not found."
        case .invalidQuery:
            return "The specified query was not valid."
        case .invalidValue:
            return "An invalid value was detected."
        case .callbackFailed:
            return "A callback has failed."
        case .aclDeleteFailed:
            return "An ACL delete operation has failed."
        case .aclReplaceFailed:
            return "An ACL replace operation has failed."
        case .aclAddFailed:
            return "An ACL add operation has failed."
        case .aclChangeFailed:
            return "An ACL change operation has failed."
        case .invalidAccessCredentials:
            return "Invalid access credentials were encountered."
        case .invalidRecord:
            return "An invalid record was encountered."
        case .invalidACL:
            return "An invalid ACL was encountered."
        case .invalidSampleValue:
            return "An invalid sample value was encountered."
        case .incompatibleVersion:
            return "An incompatible version was encountered."
        case .privilegeNotGranted:
            return "The privilege was not granted."
        case .invalidScope:
            return "An invalid scope was encountered."
        case .pvcAlreadyConfigured:
            return "The PVC is already configured."
        case .invalidPVC:
            return "An invalid PVC was encountered."
        case .emmLoadFailed:
            return "The EMM load has failed."
        case .emmUnloadFailed:
            return "The EMM unload has failed."
        case .addinLoadFailed:
            return "The add-in load operation has failed."
        case .invalidKeyRef:
            return "An invalid key was encountered."
        case .invalidKeyHierarchy:
            return "An invalid key hierarchy was encountered."
        case .addinUnloadFailed:
            return "The add-in unload operation has failed."
        case .libraryReferenceNotFound:
            return "A library reference was not found."
        case .invalidAddinFunctionTable:
            return "An invalid add-in function table was encountered."
        case .invalidServiceMask:
            return "An invalid service mask was encountered."
        case .moduleNotLoaded:
            return "A module was not loaded."
        case .invalidSubServiceID:
            return "An invalid subservice ID was encountered."
        case .attributeNotInContext:
            return "An attribute was not in the context."
        case .moduleManagerInitializeFailed:
            return "A module failed to initialize."
        case .moduleManagerNotFound:
            return "A module was not found."
        case .eventNotificationCallbackNotFound:
            return "An event notification callback was not found."
        case .inputLengthError:
            return "An input length error was encountered."
        case .outputLengthError:
            return "An output length error was encountered."
        case .privilegeNotSupported:
            return "The privilege is not supported."
        case .deviceError:
            return "A device error was encountered."
        case .attachHandleBusy:
            return "The CSP handle was busy."
        case .notLoggedIn:
            return "You are not logged in."
        case .algorithmMismatch:
            return "An algorithm mismatch was encountered."
        case .keyUsageIncorrect:
            return "The key usage is incorrect."
        case .keyBlobTypeIncorrect:
            return "The key blob type is incorrect."
        case .keyHeaderInconsistent:
            return "The key header is inconsistent."
        case .unsupportedKeyFormat:
            return "The key header format is not supported."
        case .unsupportedKeySize:
            return "The key size is not supported."
        case .invalidKeyUsageMask:
            return "The key usage mask is not valid."
        case .unsupportedKeyUsageMask:
            return "The key usage mask is not supported."
        case .invalidKeyAttributeMask:
            return "The key attribute mask is not valid."
        case .unsupportedKeyAttributeMask:
            return "The key attribute mask is not supported."
        case .invalidKeyLabel:
            return "The key label is not valid."
        case .unsupportedKeyLabel:
            return "The key label is not supported."
        case .invalidKeyFormat:
            return "The key format is not valid."
        case .unsupportedVectorOfBuffers:
            return "The vector of buffers is not supported."
        case .invalidInputVector:
            return "The input vector is not valid."
        case .invalidOutputVector:
            return "The output vector is not valid."
        case .invalidContext:
            return "An invalid context was encountered."
        case .invalidAlgorithm:
            return "An invalid algorithm was encountered."
        case .invalidAttributeKey:
            return "A key attribute was not valid."
        case .missingAttributeKey:
            return "A key attribute was missing."
        case .invalidAttributeInitVector:
            return "An init vector attribute was not valid."
        case .missingAttributeInitVector:
            return "An init vector attribute was missing."
        case .invalidAttributeSalt:
            return "A salt attribute was not valid."
        case .missingAttributeSalt:
            return "A salt attribute was missing."
        case .invalidAttributePadding:
            return "A padding attribute was not valid."
        case .missingAttributePadding:
            return "A padding attribute was missing."
        case .invalidAttributeRandom:
            return "A random number attribute was not valid."
        case .missingAttributeRandom:
            return "A random number attribute was missing."
        case .invalidAttributeSeed:
            return "A seed attribute was not valid."
        case .missingAttributeSeed:
            return "A seed attribute was missing."
        case .invalidAttributePassphrase:
            return "A passphrase attribute was not valid."
        case .missingAttributePassphrase:
            return "A passphrase attribute was missing."
        case .invalidAttributeKeyLength:
            return "A key length attribute was not valid."
        case .missingAttributeKeyLength:
            return "A key length attribute was missing."
        case .invalidAttributeBlockSize:
            return "A block size attribute was not valid."
        case .missingAttributeBlockSize:
            return "A block size attribute was missing."
        case .invalidAttributeOutputSize:
            return "An output size attribute was not valid."
        case .missingAttributeOutputSize:
            return "An output size attribute was missing."
        case .invalidAttributeRounds:
            return "The number of rounds attribute was not valid."
        case .missingAttributeRounds:
            return "The number of rounds attribute was missing."
        case .invalidAlgorithmParms:
            return "An algorithm parameters attribute was not valid."
        case .missingAlgorithmParms:
            return "An algorithm parameters attribute was missing."
        case .invalidAttributeLabel:
            return "A label attribute was not valid."
        case .missingAttributeLabel:
            return "A label attribute was missing."
        case .invalidAttributeKeyType:
            return "A key type attribute was not valid."
        case .missingAttributeKeyType:
            return "A key type attribute was missing."
        case .invalidAttributeMode:
            return "A mode attribute was not valid."
        case .missingAttributeMode:
            return "A mode attribute was missing."
        case .invalidAttributeEffectiveBits:
            return "An effective bits attribute was not valid."
        case .missingAttributeEffectiveBits:
            return "An effective bits attribute was missing."
        case .invalidAttributeStartDate:
            return "A start date attribute was not valid."
        case .missingAttributeStartDate:
            return "A start date attribute was missing."
        case .invalidAttributeEndDate:
            return "An end date attribute was not valid."
        case .missingAttributeEndDate:
            return "An end date attribute was missing."
        case .invalidAttributeVersion:
            return "A version attribute was not valid."
        case .missingAttributeVersion:
            return "A version attribute was missing."
        case .invalidAttributePrime:
            return "A prime attribute was not valid."
        case .missingAttributePrime:
            return "A prime attribute was missing."
        case .invalidAttributeBase:
            return "A base attribute was not valid."
        case .missingAttributeBase:
            return "A base attribute was missing."
        case .invalidAttributeSubprime:
            return "A subprime attribute was not valid."
        case .missingAttributeSubprime:
            return "A subprime attribute was missing."
        case .invalidAttributeIterationCount:
            return "An iteration count attribute was not valid."
        case .missingAttributeIterationCount:
            return "An iteration count attribute was missing."
        case .invalidAttributeDLDBHandle:
            return "A database handle attribute was not valid."
        case .missingAttributeDLDBHandle:
            return "A database handle attribute was missing."
        case .invalidAttributeAccessCredentials:
            return "An access credentials attribute was not valid."
        case .missingAttributeAccessCredentials:
            return "An access credentials attribute was missing."
        case .invalidAttributePublicKeyFormat:
            return "A public key format attribute was not valid."
        case .missingAttributePublicKeyFormat:
            return "A public key format attribute was missing."
        case .invalidAttributePrivateKeyFormat:
            return "A private key format attribute was not valid."
        case .missingAttributePrivateKeyFormat:
            return "A private key format attribute was missing."
        case .invalidAttributeSymmetricKeyFormat:
            return "A symmetric key format attribute was not valid."
        case .missingAttributeSymmetricKeyFormat:
            return "A symmetric key format attribute was missing."
        case .invalidAttributeWrappedKeyFormat:
            return "A wrapped key format attribute was not valid."
        case .missingAttributeWrappedKeyFormat:
            return "A wrapped key format attribute was missing."
        case .stagedOperationInProgress:
            return "A staged operation is in progress."
        case .stagedOperationNotStarted:
            return "A staged operation was not started."
        case .verifyFailed:
            return "A cryptographic verification failure has occurred."
        case .querySizeUnknown:
            return "The query size is unknown."
        case .blockSizeMismatch:
            return "A block size mismatch occurred."
        case .publicKeyInconsistent:
            return "The public key was inconsistent."
        case .deviceVerifyFailed:
            return "A device verification failure has occurred."
        case .invalidLoginName:
            return "An invalid login name was detected."
        case .alreadyLoggedIn:
            return "The user is already logged in."
        case .invalidDigestAlgorithm:
            return "An invalid digest algorithm was detected."
        case .invalidCRLGroup:
            return "An invalid CRL group was detected."
        case .certificateCannotOperate:
            return "The certificate cannot operate."
        case .certificateExpired:
            return "An expired certificate was detected."
        case .certificateNotValidYet:
            return "The certificate is not yet valid."
        case .certificateRevoked:
            return "The certificate was revoked."
        case .certificateSuspended:
            return "The certificate was suspended."
        case .insufficientCredentials:
            return "Insufficient credentials were detected."
        case .invalidAction:
            return "The action was not valid."
        case .invalidAuthority:
            return "The authority was not valid."
        case .verifyActionFailed:
            return "A verify action has failed."
        case .invalidCertAuthority:
            return "The certificate authority was not valid."
        case .invaldCRLAuthority:
            return "The CRL authority was not valid."
        case .invalidCRLEncoding:
            return "The CRL encoding was not valid."
        case .invalidCRLType:
            return "The CRL type was not valid."
        case .invalidCRL:
            return "The CRL was not valid."
        case .invalidFormType:
            return "The form type was not valid."
        case .invalidID:
            return "The ID was not valid."
        case .invalidIdentifier:
            return "The identifier was not valid."
        case .invalidIndex:
            return "The index was not valid."
        case .invalidPolicyIdentifiers:
            return "The policy identifiers are not valid."
        case .invalidTimeString:
            return "The time specified was not valid."
        case .invalidReason:
            return "The trust policy reason was not valid."
        case .invalidRequestInputs:
            return "The request inputs are not valid."
        case .invalidResponseVector:
            return "The response vector was not valid."
        case .invalidStopOnPolicy:
            return "The stop-on policy was not valid."
        case .invalidTuple:
            return "The tuple was not valid."
        case .multipleValuesUnsupported:
            return "Multiple values are not supported."
        case .notTrusted:
            return "The trust policy was not trusted."
        case .noDefaultAuthority:
            return "No default authority was detected."
        case .rejectedForm:
            return "The trust policy had a rejected form."
        case .requestLost:
            return "The request was lost."
        case .requestRejected:
            return "The request was rejected."
        case .unsupportedAddressType:
            return "The address type is not supported."
        case .unsupportedService:
            return "The service is not supported."
        case .invalidTupleGroup:
            return "The tuple group was not valid."
        case .invalidBaseACLs:
            return "The base ACLs are not valid."
        case .invalidTupleCredendtials:
            return "The tuple credentials are not valid."
        case .invalidEncoding:
            return "The encoding was not valid."
        case .invalidValidityPeriod:
            return "The validity period was not valid."
        case .invalidRequestor:
            return "The requestor was not valid."
        case .requestDescriptor:
            return "The request descriptor was not valid."
        case .invalidBundleInfo:
            return "The bundle information was not valid."
        case .invalidCRLIndex:
            return "The CRL index was not valid."
        case .noFieldValues:
            return "No field values were detected."
        case .unsupportedFieldFormat:
            return "The field format is not supported."
        case .unsupportedIndexInfo:
            return "The index information is not supported."
        case .unsupportedLocality:
            return "The locality is not supported."
        case .unsupportedNumAttributes:
            return "The number of attributes is not supported."
        case .unsupportedNumIndexes:
            return "The number of indexes is not supported."
        case .unsupportedNumRecordTypes:
            return "The number of record types is not supported."
        case .fieldSpecifiedMultiple:
            return "Too many fields were specified."
        case .incompatibleFieldFormat:
            return "The field format was incompatible."
        case .invalidParsingModule:
            return "The parsing module was not valid."
        case .databaseLocked:
            return "The database is locked."
        case .datastoreIsOpen:
            return "The data store is open."
        case .missingValue:
            return "A missing value was detected."
        case .unsupportedQueryLimits:
            return "The query limits are not supported."
        case .unsupportedNumSelectionPreds:
            return "The number of selection predicates is not supported."
        case .unsupportedOperator:
            return "The operator is not supported."
        case .invalidDBLocation:
            return "The database location is not valid."
        case .invalidAccessRequest:
            return "The access request is not valid."
        case .invalidIndexInfo:
            return "The index information is not valid."
        case .invalidNewOwner:
            return "The new owner is not valid."
        case .invalidModifyMode:
            return "The modify mode is not valid."
        case .missingRequiredExtension:
            return "A required certificate extension is missing."
        case .extendedKeyUsageNotCritical:
            return "The extended key usage extension was not marked critical."
        case .timestampMissing:
            return "A timestamp was expected but was not found."
        case .timestampInvalid:
            return "The timestamp was not valid."
        case .timestampNotTrusted:
            return "The timestamp was not trusted."
        case .timestampServiceNotAvailable:
            return "The timestamp service is not available."
        case .timestampBadAlg:
            return "An unrecognized or unsupported Algorithm Identifier in timestamp."
        case .timestampBadRequest:
            return "The timestamp transaction is not permitted or supported."
        case .timestampBadDataFormat:
            return "The timestamp data submitted has the wrong format."
        case .timestampTimeNotAvailable:
            return "The time source for the Timestamp Authority is not available."
        case .timestampUnacceptedPolicy:
            return "The requested policy is not supported by the Timestamp Authority."
        case .timestampUnacceptedExtension:
            return "The requested extension is not supported by the Timestamp Authority."
        case .timestampAddInfoNotAvailable:
            return "The additional information requested is not available."
        case .timestampSystemFailure:
            return "The timestamp request cannot be handled due to system failure."
        case .signingTimeMissing:
            return "A signing time was expected but was not found."
        case .timestampRejection:
            return "A timestamp transaction was rejected."
        case .timestampWaiting:
            return "A timestamp transaction is waiting."
        case .timestampRevocationWarning:
            return "A timestamp authority revocation warning was issued."
        case .timestampRevocationNotification:
            return "A timestamp authority revocation notification was issued."
        case .unexpectedError:
            return "Unexpected error has occurred."
        }
    }
}

extension Status: CustomNSError {
    public static let errorDomain = "com.radixdlt.radidxswift.status.error"
    
    public var errorCode: Int {
        return Int(rawValue)
    }
    
    public var errorUserInfo: [String: Any] {
        return [NSLocalizedDescriptionKey: description]
    }
}
// swiftlint:enable all
