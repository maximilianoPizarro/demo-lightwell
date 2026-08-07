package com.redhat.lightwell.demo;

import org.apache.commons.io.IOUtils;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = {"/", "/health"})
public class HealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        String commonsIoVersion = IOUtils.class.getPackage().getImplementationVersion();
        if (commonsIoVersion == null) {
            commonsIoVersion = "2.11.0.rhlw-00001 (classpath)";
        }
        String body = "<!DOCTYPE html><html><head><title>Lightwell Demo</title></head><body>"
                + "<h1>Lightwell Java Demo</h1>"
                + "<p>Legacy JBoss-style WAR resolving deps via Lightwell.</p>"
                + "<p>commons-io: <code>" + commonsIoVersion + "</code></p>"
                + "<p>Status: <strong>OK</strong></p>"
                + "</body></html>";
        try (InputStream ignored = IOUtils.toInputStream(body, StandardCharsets.UTF_8)) {
            resp.getWriter().write(body);
        }
    }
}
