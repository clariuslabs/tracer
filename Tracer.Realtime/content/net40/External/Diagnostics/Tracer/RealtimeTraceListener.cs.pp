﻿#region BSD License
/* 
Copyright (c) 2011, Clarius Consulting
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list 
  of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this 
  list of conditions and the following disclaimer in the documentation and/or other 
  materials provided with the distribution.

* Neither the name of Clarius Consulting nor the names of its contributors may be 
  used to endorse or promote products derived from this software without specific 
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
DAMAGE.
*/
#endregion

namespace $rootnamespace$
{
    using Microsoft.AspNet.SignalR.Client;
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Diagnostics;
    using System.Globalization;

    public class RealtimeTraceListener : TraceListener
    {
        /// <summary>
        /// The SignalR hosted hub. Change to your own host URL if self-hosting.
        /// </summary>
        const string TracerHubUrl = "http://tracer.azurewebsites.net/";
        const string HubName = "Tracer";

        static readonly string hubUrl;
        string groupName;
        HubConnection hub;
        IHubProxy proxy;

        /// <summary>
        /// Initializes the Hub URL from the <c>HubUrl</c> appSettings configuration 
        /// value, or sets it to the default tracer hub.
        /// </summary>
        static RealtimeTraceListener()
        {
            hubUrl = ConfigurationManager.AppSettings["HubUrl"];
            if (string.IsNullOrEmpty(hubUrl))
                hubUrl = TracerHubUrl;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="RealtimeTraceListener"/> class.
        /// </summary>
        /// <param name="groupName">Name of the group within the hub to broadcast traces to.</param>
        public RealtimeTraceListener(string groupName)
        {
            if (string.IsNullOrEmpty(groupName))
                throw new ArgumentException("String value for groupName cannot be empty or null.", "groupName");

            this.groupName = groupName;
        }

        public override void TraceEvent(TraceEventCache eventCache, string source, TraceEventType eventType, int id, string message)
        {
            if ((this.Filter == null) || this.Filter.ShouldTrace(eventCache, source, eventType, id, message, null, null, null))
            {
                DoTraceEvent(eventCache, source, eventType, id, message);
            }
        }

        public override void TraceEvent(TraceEventCache eventCache, string source, TraceEventType eventType, int id, string format, params object[] args)
        {
            if ((this.Filter == null) || this.Filter.ShouldTrace(eventCache, source, eventType, id, format, args, null, null))
            {
                if (args == null || args.Length == 0)
                    DoTraceEvent(eventCache, source, eventType, id, format);
                else
                    DoTraceEvent(eventCache, source, eventType, id, string.Format(CultureInfo.InvariantCulture, format, args));
            }
        }

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            if (hub != null)
                hub.Dispose();
        }

        // NOTE: Tracer.SystemDiagnostics for .NET 4.0+ (required to use this listener)
        // always traces asynchronously, so it's fine to just Wait() here for the connection, 
        // since this would NOT be slowing down the app in any way. Also, Tracer will trace 
        // in a single background thread, so this is automatically "thread-safe" without needing 
        // an explicit lock.
        private void DoTraceEvent(TraceEventCache eventCache, string source, TraceEventType eventType, int id, string message)
        {
            if (hub == null)
            {
                var data = new Dictionary<string, string>
                {
                    { "groupName", groupName }
                };

                hub = new HubConnection(hubUrl, data);
                proxy = hub.CreateHubProxy(HubName);
                hub.Start().Wait();
            }

            proxy.Invoke("BroadcastTraceEvent", new TraceEvent
            {
                EventType = eventType,
                Source = source,
                Message = message,
            });
        }

        public override void Write(string message)
        {
        }

        public override void WriteLine(string message)
        {
        }
    }
}
