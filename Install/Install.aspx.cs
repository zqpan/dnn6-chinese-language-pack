#region Copyright

// 
// DotNetNukeŽ - http://www.dotnetnuke.com
// Copyright (c) 2002-2011
// by DotNetNuke Corporation
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
// to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions 
// of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.

#endregion

#region Usings

using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Xml;

using DotNetNuke.Application;
using DotNetNuke.Common;
using DotNetNuke.Common.Utilities;
using DotNetNuke.Data;
using DotNetNuke.Framework.Providers;
using DotNetNuke.Instrumentation;
using DotNetNuke.Services.Scheduling;

#endregion
//********************************************
//********************************************
//********************************************
//        IMPORTANT READ THIS
//  During upgrades this file may run with plain old .net 2.0 compilers
//  Be careful of the language features you use here.
//  Do not use:
//      var
//      add more to the list as you find them
//********************************************
//********************************************
//********************************************
namespace DotNetNuke.Services.Install
{
    public partial class Install : Page
    {
		#region "Private Methods"

        private void ExecuteScripts()
        {
            //Start Timer
            Upgrade.Upgrade.StartTimer();

            //Write out Header
            HtmlUtils.WriteHeader(Response, "executeScripts");

            Response.Write("<h2>Execute Scripts Status Report</h2>");
            Response.Flush();

            string strProviderPath = DataProvider.Instance().GetProviderPath();
            if (!strProviderPath.StartsWith("ERROR:"))
            {
                Upgrade.Upgrade.ExecuteScripts(strProviderPath);
            }
            Response.Write("<h2>Execution Complete</h2>");
            Response.Flush();


            //Write out Footer
            HtmlUtils.WriteFooter(Response);
        }

        private void InstallApplication()
        {
            //the application uses a two step installation process. The first step is used to update 
            //the Web.config with any configuration settings - which forces an application restart. 
            //The second step finishes the installation process and provisions the site.

            string installationDate = Config.GetSetting("InstallationDate");

            if (installationDate == null || String.IsNullOrEmpty(installationDate))
            {
                string strError = Config.UpdateMachineKey();
                if (String.IsNullOrEmpty(strError))
                {
					//send a new request to the application to initiate step 2
                    Response.Redirect(HttpContext.Current.Request.RawUrl, true);
                }
                else
                {
					//403-3 Error - Redirect to ErrorPage
                    string strURL = "~/ErrorPage.aspx?status=403_3&error=" + strError;
                    HttpContext.Current.Response.Clear();
                    HttpContext.Current.Server.Transfer(strURL);
                }
            }
            else
            {
				//Start Timer
                Upgrade.Upgrade.StartTimer();

                //Write out Header
                HtmlUtils.WriteHeader(Response, "install");

                //get path to script files
                string strProviderPath = DataProvider.Instance().GetProviderPath();
                if (!strProviderPath.StartsWith("ERROR:"))
                {
                    Response.Write("<h2>Version: " + Globals.FormatVersion(DotNetNukeContext.Current.Application.Version) + "</h2>");
                    Response.Flush();

                    Response.Write("<br><br>");
                    Response.Write("<h2>Installation Status Report</h2>");
                    Response.Flush();

                    if (!CheckPermissions())
                    {
                        return;
                    }
                    Upgrade.Upgrade.InstallDNN(strProviderPath);

                    Response.Write("<h2>Installation Complete</h2>");
                    Response.Write("<br><br><h2><a href='../Default.aspx'>Click Here To Access Your Portal</a></h2><br><br>");
                    Response.Flush();

                    //log APPLICATION_START event
                    Initialize.LogStart();

                    //Start Scheduler
                    Initialize.StartScheduler();
                }
                else
                {
					//upgrade error
                    Response.Write("<h2>Upgrade Error: " + strProviderPath + "</h2>");
                    Response.Flush();
                }
				
                //Write out Footer
                HtmlUtils.WriteFooter(Response);
            }
        }

        private void UpgradeApplication()
        {
            //Start Timer
            Upgrade.Upgrade.StartTimer();

            //Write out Header
            HtmlUtils.WriteHeader(Response, "upgrade");

            Response.Write("<h2>Current Assembly Version: " + Globals.FormatVersion(DotNetNukeContext.Current.Application.Version) + "</h2>");
            Response.Flush();

            //get path to script files
            string strProviderPath = DataProvider.Instance().GetProviderPath();
            if (!strProviderPath.StartsWith("ERROR:"))
            {
                string strDatabaseVersion;

                //get current database version
                IDataReader dr = DataProvider.Instance().GetDatabaseVersion();
                if (dr.Read())
                {
					//Call Upgrade with the current DB Version to upgrade an
                    //existing DNN installation
                    int majVersion = Convert.ToInt32(dr["Major"]);
                    int minVersion = Convert.ToInt32(dr["Minor"]);
                    int buildVersion = Convert.ToInt32(dr["Build"]);
                    strDatabaseVersion = majVersion.ToString("00") + "." + minVersion.ToString("00") + "." + buildVersion.ToString("00");

                    Response.Write("<h2>Current Database Version: " + strDatabaseVersion + "</h2>");
                    Response.Flush();

                    string ignoreWarning = Null.NullString;
                    string strWarning = Null.NullString;
                    if ((majVersion == 3 && minVersion < 3) || (majVersion == 4 && minVersion < 3))
                    {
						//Users and profile have not been transferred
						//Get the name of the data provider
                        ProviderConfiguration objProviderConfiguration = ProviderConfiguration.GetProviderConfiguration("data");

                        //Execute Special Script
                        Upgrade.Upgrade.ExecuteScript(strProviderPath + "Upgrade." + objProviderConfiguration.DefaultProvider);

                        if ((Request.QueryString["ignoreWarning"] != null))
                        {
                            ignoreWarning = Request.QueryString["ignoreWarning"].ToLower();
                        }
                        strWarning = Upgrade.Upgrade.CheckUpgrade();
                    }
                    else
                    {
                        ignoreWarning = "true";
                    }
					
                    //Check whether Upgrade is ok
                    if (strWarning == Null.NullString || ignoreWarning == "true")
                    {
                        Response.Write("<br><br>");
                        Response.Write("<h2>Upgrade Status Report</h2>");
                        Response.Flush();
                        //stop scheduler
                        SchedulingProvider.Instance().Halt("Stopped by Upgrade Process");

                        Upgrade.Upgrade.UpgradeDNN(strProviderPath, DataProvider.Instance().GetVersion());

                        //Install optional resources if present
                        Upgrade.Upgrade.InstallPackages("Module", true);
                        Upgrade.Upgrade.InstallPackages("Skin", true);
                        Upgrade.Upgrade.InstallPackages("Container", true);
                        Upgrade.Upgrade.InstallPackages("Language", true);
                        Upgrade.Upgrade.InstallPackages("Provider", true);
                        Upgrade.Upgrade.InstallPackages("AuthSystem", true);
                        Upgrade.Upgrade.InstallPackages("Package", true);

                        Response.Write("<h2>Upgrade Complete</h2>");
                        Response.Write("<br><br><h2><a href='../Default.aspx'>Click Here To Access Your Portal</a></h2><br><br>");
                    }
                    else
                    {
                        Response.Write("<h2>Warning:</h2>" + strWarning.Replace(Environment.NewLine, "<br />"));

                        Response.Write("<br><br><a href='Install.aspx?mode=upgrade&ignoreWarning=true'>Click Here To Proceed With The Upgrade.</a>");
                    }
                    Response.Flush();
                }
                dr.Close();
            }
            else
            {
                Response.Write("<h2>Upgrade Error: " + strProviderPath + "</h2>");
                Response.Flush();
            }
			
            //Write out Footer
            HtmlUtils.WriteFooter(Response);
        }

        private void AddPortal()
        {
            //Start Timer
            Upgrade.Upgrade.StartTimer();

            //Write out Header
            HtmlUtils.WriteHeader(Response, "addPortal");
            Response.Write("<h2>Add Portal Status Report</h2>");
            Response.Flush();

            //install new portal(s)
            string strNewFile = Globals.ApplicationMapPath + "\\Install\\Portal\\Portals.resources";
            if (File.Exists(strNewFile))
            {
                XmlDocument xmlDoc = new XmlDocument();
                XmlNodeList nodes;
                int intPortalId;
                xmlDoc.Load(strNewFile);

                //parse portal(s) if available
                nodes = xmlDoc.SelectNodes("//dotnetnuke/portals/portal");
                foreach (XmlNode node in nodes)
                {
                    if (node != null)
                    {
                        intPortalId = Upgrade.Upgrade.AddPortal(node, true, 0);
                    }
                }
				
                //delete the file
                try
                {
                    File.SetAttributes(strNewFile, FileAttributes.Normal);
                    File.Delete(strNewFile);
                }
				catch (Exception ex)
				{
					//error removing the file
					DnnLog.Error(ex);
				}
                Response.Write("<h2>Installation Complete</h2>");
                Response.Write("<br><br><h2><a href='../Default.aspx'>Click Here To Access Your Portal</a></h2><br><br>");
                Response.Flush();
            }

            //Write out Footer
            HtmlUtils.WriteFooter(Response);
        }

        private void InstallResources()
        {
            //Start Timer
            Upgrade.Upgrade.StartTimer();

            //Write out Header
            HtmlUtils.WriteHeader(Response, "installResources");

            Response.Write("<h2>Install Resources Status Report</h2>");
            Response.Flush();

            //install new resources(s)
            Upgrade.Upgrade.InstallPackages("Module", true);
            Upgrade.Upgrade.InstallPackages("Skin", true);
            Upgrade.Upgrade.InstallPackages("Container", true);
            Upgrade.Upgrade.InstallPackages("Language", true);
            Upgrade.Upgrade.InstallPackages("Provider", true);
            Upgrade.Upgrade.InstallPackages("AuthSystem", true);
            Upgrade.Upgrade.InstallPackages("Package", true);

            Response.Write("<h2>Installation Complete</h2>");
            Response.Write("<br><br><h2><a href='../Default.aspx'>Click Here To Access Your Portal</a></h2><br><br>");
            Response.Flush();

            //Write out Footer
            HtmlUtils.WriteFooter(Response);
        }

        private void NoUpgrade()
        {
			//get path to script files
            string strProviderPath = DataProvider.Instance().GetProviderPath();
            if (!strProviderPath.StartsWith("ERROR:"))
            {
                string strDatabaseVersion;
				//get current database version
                try
                {
                    IDataReader dr = DataProvider.Instance().GetDatabaseVersion();
                    if (dr.Read())
                    {
						//Write out Header
                        HtmlUtils.WriteHeader(Response, "none");
                        string currentAssembly = DotNetNukeContext.Current.Application.Version.ToString(3);
                        string currentDatabase = dr["Major"] + "." + dr["Minor"] + "." + dr["Build"];
                        //do not show versions if the same to stop information leakage
                        if (currentAssembly == currentDatabase)
                        {
                            Response.Write("<h2>Current Assembly Version && current Database Version are identical.</h2>");
                        }
                        else
                        {
                            Response.Write("<h2>Current Assembly Version: " + currentAssembly + "</h2>");
                            //Call Upgrade with the current DB Version to upgrade an
                            //existing DNN installation
                            strDatabaseVersion = ((int) dr["Major"]).ToString("00") + "." + ((int) dr["Minor"]).ToString("00") + "." + ((int) dr["Build"]).ToString("00");
                            Response.Write("<h2>Current Database Version: " + strDatabaseVersion + "</h2>");
                        }
                        
                        Response.Write("<br><br><a href='Install.aspx?mode=Install'>Click Here To Upgrade DotNetNuke</a>");
                        Response.Flush();
                    }
                    else
                    {
						//Write out Header
                        HtmlUtils.WriteHeader(Response, "noDBVersion");
                        Response.Write("<h2>Current Assembly Version: " + DotNetNukeContext.Current.Application.Version.ToString(3) + "</h2>");

                        Response.Write("<h2>Current Database Version: N/A</h2>");
                        Response.Write("<br><br><h2><a href='Install.aspx?mode=Install'>Click Here To Install DotNetNuke</a></h2>");
                        Response.Flush();
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
					//Write out Header
                    DnnLog.Error(ex);
                    HtmlUtils.WriteHeader(Response, "error");
                    Response.Write("<h2>Current Assembly Version: " + DotNetNukeContext.Current.Application.Version.ToString(3) + "</h2>");

                    Response.Write("<h2>" + ex.Message + "</h2>");
                    Response.Flush();
                }
            }
            else
            {
				//Write out Header
                HtmlUtils.WriteHeader(Response, "error");
                Response.Write("<h2>Current Assembly Version: " + DotNetNukeContext.Current.Application.Version.ToString(3) + "</h2>");

                Response.Write("<h2>" + strProviderPath + "</h2>");
                Response.Flush();
            }
			
			//Write out Footer
            HtmlUtils.WriteFooter(Response);
        }
		
		#endregion

		#region "Event Handlers"

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
			
			//Get current Script time-out
            int scriptTimeOut = Server.ScriptTimeout;

            string mode = "";
            if ((Request.QueryString["mode"] != null))
            {
                mode = Request.QueryString["mode"].ToLower();
            }
			
            //Disable Client side caching
            Response.Cache.SetCacheability(HttpCacheability.ServerAndNoCache);

            //Check mode is not Nothing
            if (mode == "none")
            {
                NoUpgrade();
            }
            else
            {
				//Set Script timeout to MAX value
                Server.ScriptTimeout = int.MaxValue;

                switch (Globals.Status)
                {
                    case Globals.UpgradeStatus.Install:
                        InstallApplication();
						
                        //Force an App Restart
                        Config.Touch();
                        break;
                    case Globals.UpgradeStatus.Upgrade:
                        UpgradeApplication();
                        
						//Force an App Restart
						Config.Touch();
                        break;
                    case Globals.UpgradeStatus.None:
                        //Check mode
						switch (mode)
                        {
                            case "addportal":
                                AddPortal();
                                break;
                            case "installresources":
                                InstallResources();
                                break;
                            case "executescripts":
                                ExecuteScripts();
                                break;
                        }
                        break;
                    case Globals.UpgradeStatus.Error:
                        NoUpgrade();
                        break;
                }
				
				//restore Script timeout
                Server.ScriptTimeout = scriptTimeOut;
            }
        }

        private bool CheckPermissions()
        {
            bool verified = new FileSystemPermissionVerifier(Server.MapPath("~")).VerifyAll();
            HtmlUtils.WriteFeedback(HttpContext.Current.Response,
                                    0,
                                    "Checking File and Folder permissions " + (verified ? "<font color='green'>Success</font>" : "<font color='red'>Error</font>") + "<br>");
            Response.Flush();

            return verified;
        }
		
		#endregion
    }
}