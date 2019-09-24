==================================================
 README for "RICOH THETA SDK for iOS"

 Version :0.2.1
==================================================

This file is an explanation document for RICOH THETA SDK for iOS.
lib-ricoh-theta and lib-r-exif are libraries for creating apps for iOS.
ricoh-theta-sample-for-ios is a sample app created using the libraries mentioned above.
However, this document assumes that you have already registered as an iOS developer and that you are able to develop apps for iOS.

----------------------------------------

* Contents of this Document

    * Terms of Service
    * Files included in the archive
    * Required environment for development
    * How to Use
    * Latest information
    * Troubleshooting
    * Trademarks
    * Update History

----------------------------------------

* Terms of Service

    Terms of service are included in the LICENSE.txt (LICENSE_ja.txt) file.
    It is assumed that you have agreed to these terms of service when you start using RICOH THETA SDK.

----------------------------------------

* Files included in the archive

    README.txt: This file (English)
    README_ja.txt: This file (Japanese)
    LICENSE.txt: Terms of service file (English)
    LICENSE_ja.txt: Terms of service file (Japanese)
    ricoh-theta-sample-for-ios: Sample app
    lib
    ┣ lib-ricoh-theta: Library about operations of RICOH THETA
    ┣ lib-r-exif: Library that enables acquisition of EXIF information from spherical images shot using RICOH THETA.
    ┣ lib-ricoh-theta_serializer: Library that enables easier use of lib-ricoh-theta
    ┗ doc: Document about the libraries

----------------------------------------

* Required environment for development

    [About RICOH THETA]
      Dedicated RICOH THETA library that fulfills the following conditions.

      * Hardware
          RICOH THETA (2013 launch Model)
          RICOH THETA (Model:RICOH THETA m15)
      * Firmware
          Version 1.21 or higher
          (Method for checking and updating the firmware:  https://theta360.com/en/support/manual/content/pc/pc_05.html)


    [About the Development Environment for Sample Application]
      Operation of the sample application has been verified under the following conditions.

      * Verified operating environment
          iPhone 5s
      * Development/Build Environment
          Xcode 6.0.1

----------------------------------------

* How to Use

    [Operating the Sample Application]
        1. Open and execute ricoh-theta-sample-for-ios from Xcode. The sample application is registered in the iOS device.
        2. Connect the RICOH THETA to the iOS device using Wi-Fi.
            (Usage instructions, connecting the camera to a smartphone: https://theta360.com/en/support/manual/content/prepare/prepare_06.html)
        3. The sample application can be operated

    [Using your own app with RICOH THETA SDK]
        1. Copy lib-ricoh-theta, lib-r-exif and lib-ricoh-theta_serializer into the lib of your app.
        2. Add framework and dylib. Requirements for using the library are written in the README files contained in each of the library folders.
        3. Mount based on the sample application and information described below.

    [More detailed information]
        See the contents of the provided library and documents, as well as documents on the Internet for further information.

        https://developers.theta360.com/en/docs/

----------------------------------------

* Latest information

    The latest information is released on the "RICOH THETA Developers" website.

    https://developers.theta360.com/

----------------------------------------

* Troubleshooting

    FAQs are available on the forums.

    https://developers.theta360.com/en/forums/viewforum.php?f=6

----------------------------------------

* Trademarks

    The products and services described in this document are the trademarks or registered trademarks of their respective owners.

    * iPhone and Xcode are trademarks of Apple Inc.
    * iOS is a trademark or registered trademark of Cisco in the U.S. and other countries, and is used under license. 
    * Wi-Fi is the trademark of Wi-Fi Alliance.

    All other trademarks belong to their respective owners.

----------------------------------------

* Update History

    11/10/2014 0.2.1 Added missing import statement
    11/06/2014 0.2.0 Documents are translated
    10/28/2014 0.1.0 Initial release
