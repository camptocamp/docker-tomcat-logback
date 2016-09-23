package com.camptocamp.tomcatlogback;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import ch.qos.logback.classic.pattern.ClassicConverter;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.classic.util.LevelToSyslogSeverity;
import ch.qos.logback.core.net.SyslogAppenderBase;

public class Iso8601SyslogStartConverter extends ClassicConverter
{
    private SimpleDateFormat dateFormat;
    String localHostName;
    int facility;


    @Override
    public void start() {
        int errorCount = 0;

        String facilityStr = getFirstOption();
        if (facilityStr == null) {
            addError("was expecting a facility string as an option");
            return;
        }
        facility = SyslogAppenderBase.facilityStringToint(facilityStr);
        localHostName = getLocalHostname();
        try {
            final TimeZone tz = TimeZone.getTimeZone("UTC");
            dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
            dateFormat.setTimeZone(tz);
        } catch (IllegalArgumentException e) {
            addError("Could not instantiate SimpleDateFormat", e);
            errorCount++;
        }
        if (errorCount == 0) {
            super.start();
        }
    }

    String computeTimeStampString(long now) {
        final Date nowDate = new Date(now);
        return dateFormat.format(nowDate);
    }

    public String convert(ILoggingEvent event) {
        final StringBuilder sb = new StringBuilder();

        final int pri = facility + LevelToSyslogSeverity.convert(event);

        sb.append("<");
        sb.append(pri);
        sb.append(">");
        sb.append(computeTimeStampString(event.getTimeStamp()));
        sb.append(' ');
        sb.append(localHostName);
        sb.append(' ');

        return sb.toString();
    }

    /**
     * This method gets the network name of the machine we are running on.
     * Returns "UNKNOWN_LOCALHOST" in the unlikely case where the host name
     * cannot be found.
     * @return String the name of the local host
     */
    public String getLocalHostname() {
        try {
            final InetAddress addr = InetAddress.getLocalHost();
            return addr.getHostName();
        } catch (UnknownHostException uhe) {
            addError("Could not determine local host name", uhe);
            return "UNKNOWN_LOCALHOST";
        }
    }
}
