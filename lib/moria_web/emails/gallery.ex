defmodule MoriaWeb.Emails.Gallery do
  use Swoosh.Gallery

  preview("/weekly-brief", MoriaWeb.Emails.BriefMailer)
end
