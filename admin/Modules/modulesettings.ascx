<%@ Control Language="C#" AutoEventWireup="false" Inherits="DotNetNuke.Modules.Admin.Modules.ModuleSettingsPage" CodeFile="ModuleSettings.ascx.cs" %>
<%@ Register TagPrefix="dnn" TagName="URL" Src="~/controls/URLControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Security.Permissions.Controls" Assembly="DotNetNuke" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.UI.WebControls" Assembly="DotNetNuke" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.UI.WebControls" Assembly="DotNetNuke.Web" %>
<%@ Register TagPrefix="dnn" TagName="Audit" Src="~/controls/ModuleAuditControl.ascx" %>
<%@ Register TagPrefix="dnn" TagName="ModuleLocalization" Src="~/Admin/Modules/ModuleLocalization.ascx" %>
<%@ Register TagPrefix="dnnweb" Assembly="DotNetNuke.Web" Namespace="DotNetNuke.Web.UI.WebControls" %>
<div class="dnnForm dnnModuleSettings dnnClear" id="dnnModuleSettings">
    <ul class="dnnAdminTabNav dnnClear">
        <li><a href="#msModuleSettings"><%=LocalizeString("ModuleSettings")%></a></li>
        <li><a href="#msPermissions"><%=LocalizeString("Permissions")%></a></li>
        <li><a href="#msPageSettings"><%=LocalizeString("PageSettings")%></a></li>
        <li id="specificSettingsTab" runat="server">
            <asp:HyperLink href="#msSpecificSettings" ID="hlSpecificSettings" runat="server" />
        </li>
    </ul>
    <div class="msModuleSettings dnnClear" id="msModuleSettings">
        <div class="dnnFormExpandContent">
            <a href=""><%=Localization.GetString("ExpandAll", Localization.SharedResourceFile)%></a>
        </div>
        <div class="msmsContent dnnClear">
            <h2 id="dnnPanel-ModuleGeneralDetails" class="dnnFormSectionHead"><a href="" class="dnnSectionExpanded"><%=LocalizeString("GeneralDetails")%></a></h2>
            <fieldset>
                <div class="dnnFormItem" id="cultureRow" runat="server">
                    <dnn:label id="cultureLabel" runat="server" controlname="cultureLanguageLabel" />
                    <dnn:dnnlanguagelabel id="cultureLanguageLabel" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plFriendlyName" runat="server" controlname="txtFriendlyName" />
                    <asp:TextBox ID="txtFriendlyName" runat="server" Enabled="False" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plTitle" runat="server" controlname="txtTitle" />
                    <asp:TextBox ID="txtTitle" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plTags" runat="server" controlname="termsSelector" />
                    <dnn:termsselector id="termsSelector" runat="server" height="250px" width="525px" />
                </div>
            </fieldset>
            <h2 id="dnnPanel-ModuleSecuritySettings" class="dnnFormSectionHead"><a href="" class="dnnSectionExpanded"><%=LocalizeString("Security")%></a></h2>
            <fieldset>
                <div class="dnnFormItem" id="rowAllTabs" runat="server">
                    <dnn:label id="plAllTabs" runat="server" controlname="chkAllTabs" />
                    <asp:CheckBox ID="chkAllTabs" runat="server" AutoPostBack="true" />
                </div>
                <div class="dnnFormItem" id="trnewPages" runat="server">
                    <dnn:label id="plNewTabs" runat="server" controlname="chkNewTabs" />
                    <asp:CheckBox ID="chkNewTabs" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plAdminBorder" runat="server" controlname="chkAdminBorder" />
                    <asp:CheckBox ID="chkAdminBorder" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plHeader" runat="server" controlname="txtHeader" />
                    <asp:TextBox ID="txtHeader" runat="server" TextMode="MultiLine" Rows="6" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plFooter" runat="server" controlname="txtFooter" />
                    <asp:TextBox ID="txtFooter" runat="server" TextMode="MultiLine" Rows="6" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plStartDate" runat="server" controlname="txtStartDate" />
                    <dnn:dnndatepicker id="startDatePicker" runat="server" />
                    <asp:CompareValidator ID="valtxtStartDate" ControlToValidate="startDatePicker" Operator="DataTypeCheck"
                        Type="Date" runat="server" Display="Dynamic" resourcekey="valStartDate.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plEndDate" runat="server" controlname="txtEndDate" />
                    <dnn:dnndatepicker id="endDatePicker" runat="server" />
                    <asp:CompareValidator ID="valtxtEndDate" ControlToValidate="endDatePicker" Operator="DataTypeCheck"
                        Type="Date" runat="server" Display="Dynamic" resourcekey="valEndDate.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                    <asp:CompareValidator ID="val2txtEndDate" ControlToValidate="endDatePicker" ControlToCompare="startDatePicker"
                        Operator="GreaterThanEqual" Type="Date" runat="server" Display="Dynamic" resourcekey="valEndDate2.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                </div>
            </fieldset>
            <h2 id="dnnPanel-ModuleAdditionalPages" class="dnnFormSectionHead">
                <a href="" class="dnnSectionExpanded">
                    <%=LocalizeString("ModuleInstalledOn")%></a></h2>
            <fieldset>
                <div>
                    <div class="dnnFormItem">
                        <dnnweb:DnnGrid ID="dgOnTabs" runat="server" AutoGenerateColumns="False" AllowPaging="true" PageSize="20">
                            <MasterTableView>
                                <Columns>
                                    <dnnweb:DnnGridTemplateColumn HeaderText="Page">
                                        <ItemTemplate>
                                            <%#GetInstalledOnLink(Container.DataItem)%>
                                        </ItemTemplate>
                                    </dnnweb:DnnGridTemplateColumn>
                                </Columns>
                                <NoRecordsTemplate>
                                    <div class="dnnFormMessage dnnFormWarning">
                                        <asp:Label ID="lblNoRecords" runat="server" resourcekey="lblNoRecords" />
                                    </div>
                                </NoRecordsTemplate>
                            </MasterTableView>
                        </dnnweb:DnnGrid>
                    </div>   
                </div>
            </fieldset>
        </div>
    </div>
    <div class="msPermissions dnnClear" id="msPermissions">
        <div class="mspContent dnnClear">
            <fieldset>
                <div id="permissionsRow" runat="server">
                    <dnn:modulepermissionsgrid id="dgPermissions" runat="server" />
                    <asp:CheckBox ID="chkInheritPermissions" AutoPostBack="true" runat="server" resourcekey="InheritPermissions" />
                </div>
            </fieldset>
        </div>
    </div>
    <div class="msPageSettings dnnClear" id="msPageSettings">
        <div class="dnnFormExpandContent">
            <a href="">
                <%=Localization.GetString("ExpandAll", Localization.SharedResourceFile)%></a></div>
        <div class="mspsContent dnnClear">
            <h2 id="dnnPanel-ModuleAppearance" class="dnnFormSectionHead">
                <a href="" class="dnnSectionExpanded">
                    <%=LocalizeString("Appearance")%></a></h2>
            <fieldset>
                <div class="dnnFormItem">
                    <dnn:label id="plIcon" runat="server" controlname="ctlIcon" />
                    <div class="dnnLeft">
                        <dnn:url id="ctlIcon" runat="server" showimages="true" showurls="False" showtabs="False"
                            showlog="False" showtrack="false" required="False" shownone="true" />
                    </div>
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plAlign" runat="server" controlname="cboAlign" />
                    <div class="dnnLeft">
                        <asp:RadioButtonList ID="cboAlign" CssClass="dnnFormRadioButtons" runat="server"
                            RepeatLayout="Flow">
                            <asp:ListItem resourcekey="Left" Value="left" />
                            <asp:ListItem resourcekey="Center" Value="center" />
                            <asp:ListItem resourcekey="Right" Value="right" />
                            <asp:ListItem resourcekey="Not_Specified" Value="" />
                        </asp:RadioButtonList>
                    </div>
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plColor" runat="server" controlname="txtColor" />
                    <asp:TextBox ID="txtColor" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plBorder" runat="server" controlname="txtBorder" />
                    <asp:TextBox ID="txtBorder" runat="server" MaxLength="1" />
                    <asp:CompareValidator ID="valBorder" ControlToValidate="txtBorder" Operator="DataTypeCheck"
                        Type="Integer" runat="server" Display="Dynamic" resourcekey="valBorder.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plVisibility" runat="server" controlname="cboVisibility" />
                    <asp:RadioButtonList ID="cboVisibility" CssClass="dnnFormRadioButtons" runat="server"
                        RepeatLayout="Flow">
                        <asp:ListItem resourcekey="Maximized" Value="0" />
                        <asp:ListItem resourcekey="Minimized" Value="1" />
                        <asp:ListItem resourcekey="None" Value="2" />
                    </asp:RadioButtonList>
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plDisplayTitle" runat="server" controlname="chkDisplayTitle" />
                    <asp:CheckBox ID="chkDisplayTitle" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plDisplayPrint" runat="server" controlname="chkDisplayPrint" />
                    <asp:CheckBox ID="chkDisplayPrint" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plDisplaySyndicate" runat="server" controlname="chkDisplaySyndicate" />
                    <asp:CheckBox ID="chkDisplaySyndicate" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plWebSlice" runat="server" controlname="chkWebSlice" />
                    <asp:CheckBox ID="chkWebSlice" runat="server" AutoPostBack="true" />
                </div>
                <div class="dnnFormItem" id="webSliceTitle" runat="server">
                    <dnn:label id="plWebSliceTitle" runat="server" controlname="txtWebSliceTitle" />
                    <asp:TextBox ID="txtWebSliceTitle" runat="server" />
                </div>
                <div class="dnnFormItem" id="webSliceExpiry" runat="server">
                    <dnn:label id="plWebSliceExpiry" runat="server" controlname="txtWebSliceExpiry" />
                    <dnn:dnndatepicker ID="diWebSliceExpiry" runat="server" />
                    <asp:CompareValidator ID="valWebSliceExpiry" ControlToValidate="diWebSliceExpiry"
                        Operator="DataTypeCheck" Type="Date" runat="server" Display="Dynamic" resourcekey="valWebSliceExpiry.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                </div>
                <div class="dnnFormItem" id="webSliceTTL" runat="server">
                    <dnn:label id="plWebSliceTTL" runat="server" controlname="txtWebSliceTTL" />
                    <asp:TextBox ID="txtWebSliceTTL" runat="server" />
                    <asp:CompareValidator ID="valWebSliceTTL" ControlToValidate="txtWebSliceTTL" Operator="DataTypeCheck"
                        Type="Integer" runat="server" Display="Dynamic" resourcekey="valWebSliceTTL.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                </div>
                <div class="dnnFormItem dnnContainerPreview">
                    <dnn:label id="plModuleContainer" runat="server" controlname="ctlModuleContainer" />
                    <asp:DropDownList ID="moduleContainerCombo" runat="server" DataTextField="Key" DataValueField="Value" />
                    <a href="#" class="dnnSecondaryAction">
                        <%=LocalizeString("ContainerPreview")%></a>
                </div>
            </fieldset>
            <h2 id="dnnPanel-ModuleCacheSettings" class="dnnFormSectionHead">
                <a href="" class="dnnSectionExpanded">
                    <%=LocalizeString("CacheSettings")%></a></h2>
            <fieldset>
                <div class="dnnFormItem">
                    <dnn:label id="lblCacheProvider" runat="server" controlname="cboCacheProvider" resourcekey="CacheProvider" />
                    <asp:DropDownList ID="cboCacheProvider" runat="server" AutoPostBack="true" DataValueField="Key"
                        DataTextField="filteredkey" />
                    <asp:Label ID="lblCacheInherited" runat="server" resourceKey="CacheInherited" CssClass="dnnFormError" />
                </div>
                <div class="dnnFormItem" id="divCacheDuration" runat="server" visible="false">
                     <div class="dnnFormMessage dnnFormWarning">
                        <asp:Label ID="lblCacheDurationWarning" runat="server" ResourceKey="CacheDurationWarning" />                
                    </div>
                       <dnn:label id="lblCacheDuration" runat="server" controlname="txtCacheDuration" resourcekey="CacheDuration" />
                    <asp:TextBox ID="txtCacheDuration" runat="server" class="msCacheDuration"/>
                    <asp:CompareValidator ID="valCacheTime" ControlToValidate="txtCacheDuration" Operator="DataTypeCheck"
                        Type="Integer" runat="server" Display="Dynamic" resourcekey="valCacheTime.ErrorMessage"
                        CssClass="dnnFormMessage dnnFormError" />
                </div>
            </fieldset>
            <h2 id="dnnPanel-ModuleOtherSettings" class="dnnFormSectionHead">
                <a href="" class="dnnSectionExpanded">
                    <%=LocalizeString("OtherSettings")%></a></h2>
            <fieldset>
                <div class="dnnFormItem">
                    <dnn:label id="plDefault" runat="server" controlname="chkDefault" />
                    <asp:CheckBox ID="chkDefault" runat="server" />
                </div>
                <div class="dnnFormItem">
                    <dnn:label id="plAllModules" runat="server" controlname="chkAllModules" />
                    <asp:CheckBox ID="chkAllModules" runat="server" />
                </div>
                <div class="dnnFormItem" id="rowTab" runat="server">
                    <dnn:label id="plTab" runat="server" controlname="cboTab" />
                    <asp:DropDownList ID="cboTab" DataTextField="IndentedTabName" DataValueField="TabId"
                        runat="server" />
                </div>
            </fieldset>
        </div>
    </div>
    <div class="msSpecificSettings dnnClear" id="msSpecificSettings">
        <div class="mspsContent dnnClear">
            <fieldset id="fsSpecific" runat="server">
                <asp:Panel ID="pnlSpecific" runat="server" />
            </fieldset>
        </div>
    </div>
    <ul class="dnnActions dnnClear">
        <li>
            <asp:LinkButton ID="cmdUpdate" runat="server" CssClass="dnnPrimaryAction" resourcekey="cmdUpdate" /></li>
        <li>
            <asp:LinkButton ID="cmdDelete" runat="server" CssClass="dnnSecondaryAction" resourcekey="cmdDelete"
                CausesValidation="False" /></li>
        <li>
            <asp:HyperLink ID="cancelHyperLink" runat="server" CssClass="dnnSecondaryAction"
                resourcekey="cmdCancel" /></li>
    </ul>
    <div class="dnnmsStat dnnClear">
        <dnn:audit id="ctlAudit" runat="server" />
    </div>
</div>
<script language="javascript" type="text/javascript">
    /*globals jQuery, window, Sys */
    (function ($, Sys) {
        function setUpDnnModuleSettings() {
            $('#dnnModuleSettings').dnnTabs().dnnPanels();
            $('#msModuleSettings .dnnFormExpandContent a').dnnExpandAll({
                expandText: '<%=Localization.GetString("ExpandAll", Localization.SharedResourceFile)%>',
                collapseText: '<%=Localization.GetString("CollapseAll", Localization.SharedResourceFile)%>',
                targetArea: '#msModuleSettings'
            });
            $('#msPageSettings .dnnFormExpandContent a').dnnExpandAll({
                expandText: '<%=Localization.GetString("ExpandAll", Localization.SharedResourceFile)%>',
                collapseText: '<%=Localization.GetString("CollapseAll", Localization.SharedResourceFile)%>',
                targetArea: '#msPageSettings'
            });
            $('#<%= cmdDelete.ClientID %>').dnnConfirm({
                text: '<%= Localization.GetString("DeleteItem.Text", Localization.SharedResourceFile) %>',
                yesText: '<%= Localization.GetString("Yes.Text", Localization.SharedResourceFile) %>',
                noText: '<%= Localization.GetString("No.Text", Localization.SharedResourceFile) %>',
                title: '<%= Localization.GetString("Confirm.Text", Localization.SharedResourceFile) %>'
            });
            $('.dnnContainerPreview').dnnPreview({
                containerSelector: 'select',
                baseUrl: '<%= DotNetNuke.Common.Globals.NavigateURL(this.TabId) %>',
                noSelectionMessage: '<%= LocalizeString("PreviewNoSelectionMessage.Text") %>',
                alertCloseText: '<%= Localization.GetString("Close.Text", Localization.SharedResourceFile)%>',
                alertOkText: '<%= Localization.GetString("Ok.Text", Localization.SharedResourceFile)%>'
            });
        }

        $(document).ready(function () {
            setUpDnnModuleSettings();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                setUpDnnModuleSettings();
            });
        });
    } (jQuery, window.Sys));
</script>
