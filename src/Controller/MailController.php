<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;

class MailController extends AbstractController
{
    #[Route('/send-mail', name: 'send_mail')]
    public function sendMail(MailerInterface $mailer): Response
    {
        $email = (new Email())
            ->from('demo@example.com')
            ->to('test@example.com')
            ->subject('Bonjour depuis Symfony !')
            ->text('Ceci est un email de test.')
            ->html('<h2>Bonjour</h2>');

        $mailer->send($email);

        return new Response("Email envoyé !");
    }
}
