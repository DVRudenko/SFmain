<aura:application access="GLOBAL" extends="ltng:outApp" description="The Lightning Out app which hosts the phone."> 
    <aura:dependency resource="c:CTI_callInfoPanel"/>
    <ltng:require scripts="{!$Resource.SocketIO +'/SocketIO220.js'}" />
    <ltng:require scripts="{!$Resource.OpenCTI +'/opencti.js'}" />
</aura:application>