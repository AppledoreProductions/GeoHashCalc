﻿<%@ Page Language="VB" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.vb" Inherits="GeoHashCalc._Default" %>

<%@ Import Namespace="System.Security.Cryptography" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>

<%@ Register Src="~/map.ascx" TagPrefix="uc1" TagName="map" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <script runat="server">
        Private Function GetDowValue(ByVal thisDate As DateTime) As String
            Dim sReturn = IsAmericaAwakeYet(thisDate)
            If sReturn = Nothing Then
                sReturn = IsAmericaAwakeYet(thisDate.Subtract(New TimeSpan(1, 0, 0, 0)))
            End If
            Return sReturn
        End Function
        
        Private Function IsAmericaAwakeYet(ByVal thisDate As DateTime) As String
            Dim year = thisDate.Year.ToString
            Dim month = thisDate.Month.ToString
            Dim day = thisDate.Day.ToString
            Dim sURL As String
            sURL = "http://geo.crox.net/djia/" + year + "/" + month + "/" + day
            Dim wrGETURL As WebRequest = WebRequest.Create(sURL)
            Dim objStream As Stream
            Try
                objStream = wrGETURL.GetResponse.GetResponseStream()
            Catch ex As Exception
                Return Nothing
            End Try
            Dim objReader As New StreamReader(objStream)
            Dim sReturn As String = ""
            sReturn += objReader.ReadLine
            Return year + "-" + month + "-" + day + "-" + sReturn
        End Function
    
        Private Function GenerateHash(ByVal SourceText As String) As String
            Dim Md5 As New MD5CryptoServiceProvider()
            Dim bytes() As Byte = Encoding.Default.GetBytes(SourceText)
            Dim hashbytes = Md5.ComputeHash(bytes)
            Dim outStr = ""
            For Each hb In hashbytes
                outStr += Hex(hb).ToString
            Next
            Return outStr
        End Function
        
        Private todayStartString As String
        Private yesterdayStartString As String
        Private fullHash As String
        Private hash1 As String
        Private hash2 As String
        Private dechash1 As Long
        Private dechash2 As Long
        Private destLat As String
        Private destLon As String
        
        Protected Sub Page_Init() Handles Me.Init
            Dim lat = Request.QueryString("lat")
            Dim lon = Request.QueryString("lon")
            If lat = Nothing OrElse lat = "" Then
                Return
            End If
            If lon = Nothing OrElse lon = "" Then
                Return
            End If
            
            todayStartString = GetDowValue(DateTime.Now)
            yesterdayStartString = GetDowValue(DateTime.Now.Subtract(New TimeSpan(1, 0, 0, 0)))

            Dim useString = todayStartString
            If CType(lat, Double) > -30 Then
                useString = yesterdayStartString
            End If
            
            fullHash = GenerateHash(useString)
            hash1 = fullHash.Substring(0, 16)
            hash2 = fullHash.Substring(16)
            dechash1 = Convert.ToInt64(hash1, 16)
            dechash2 = Convert.ToInt64(hash2, 16)
            
            destLat = lat.Substring(0, lat.IndexOf(".")) + "." + (dechash1.ToString).Substring(0, 6)
            destLon = lon.Substring(0, lon.IndexOf(".")) + "." + (dechash2.ToString).Substring(0, 6)
        End Sub
    </script>

    <div class="row">
        <div class="col">
            <h2>hello world</h2>

            <p><i>
                Starting string west of 30W: <%= todayStartString%><br />
                    Starting string east of 30W: <%= yesterdayStartString%><br /><br />
                    MD5 hash: <%= fullHash%><br />
                    In halves: <%= hash1%>, <%= hash2%><br />
                    In decimal: <%= dechash1%>, <%= dechash2%><br />
                    Go: <%= destLat%>, <%=destLon%><br />
            </i></p>

            <h4>you are at</h4>

            <uc1:map runat="server"></uc1:map>
        </div>
    </div>

</asp:Content>
