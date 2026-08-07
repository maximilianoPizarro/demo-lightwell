package com.redhat.lightwell.demo;

import org.apache.commons.io.IOUtils;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = {"/", "/health", "/index.html"})
public class HealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        String commonsIoVersion = IOUtils.class.getPackage().getImplementationVersion();
        if (commonsIoVersion == null || commonsIoVersion.isBlank()) {
            commonsIoVersion = "2.11.0.rhlw-00001";
        }

        String path = req.getRequestURI();
        if (path != null && path.endsWith("/health")) {
            resp.getWriter().write("{\"status\":\"OK\",\"commons-io\":\"" + commonsIoVersion + "\"}\n");
            return;
        }

        String body = "<!DOCTYPE html>\n"
                + "<html lang=\"en\">\n"
                + "<head>\n"
                + "  <meta charset=\"utf-8\"/>\n"
                + "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"/>\n"
                + "  <title>Lightwell Java Demo</title>\n"
                + "  <style>\n"
                + "    :root { --rh-red:#ee0000; --ink:#151515; --muted:#6a6e73; --bg:#f5f5f5; }\n"
                + "    body { margin:0; font-family: \"Red Hat Text\", \"Segoe UI\", sans-serif;\n"
                + "      color:var(--ink); background: linear-gradient(180deg,#fff 0%, var(--bg) 100%); min-height:100vh; }\n"
                + "    main { max-width: 40rem; margin: 0 auto; padding: 3rem 1.25rem; }\n"
                + "    .eyebrow { color:var(--rh-red); font-weight:700; letter-spacing:.04em; text-transform:uppercase; font-size:.8rem; }\n"
                + "    h1 { font-family: \"Red Hat Display\", \"Segoe UI\", sans-serif; font-size:2rem; margin:.4rem 0 1rem; }\n"
                + "    p { color:var(--muted); line-height:1.5; }\n"
                + "    code { background:#fff; border:1px solid #d2d2d2; padding:.1rem .35rem; border-radius:3px; color:var(--ink); }\n"
                + "    .ok { display:inline-block; margin-top:1rem; padding:.35rem .7rem; background:#e9f7ec;\n"
                + "      color:#1e4f2b; border:1px solid #b7dfc1; border-radius:3px; font-weight:700; }\n"
                + "    ul { padding-left:1.1rem; color:var(--muted); }\n"
                + "  </style>\n"
                + "</head>\n"
                + "<body>\n"
                + "  <main>\n"
                + "    <div class=\"eyebrow\">Red Hat Lightwell Network</div>\n"
                + "    <h1>Lightwell Java Demo</h1>\n"
                + "    <p>Legacy JBoss/WildFly WAR resolving third-party dependencies through "
                + "<strong>Nexus → Lightwell validated</strong> for secure supply-chain demos.</p>\n"
                + "    <p>Resolved via Lightwell: <code>commons-io:" + commonsIoVersion + "</code></p>\n"
                + "    <div class=\"ok\">Status: OK</div>\n"
                + "    <p style=\"margin-top:1.5rem\">Secure development focus:</p>\n"
                + "    <ul>\n"
                + "      <li>CVE-aware dependency remediation (Lightwell)</li>\n"
                + "      <li>RHDA / Trusted Profile Analyzer in the IDE</li>\n"
                + "      <li>Build via OpenShift Pipelines (Tekton)</li>\n"
                + "    </ul>\n"
                + "  </main>\n"
                + "</body>\n"
                + "</html>\n";
        resp.getWriter().write(body);
    }
}
