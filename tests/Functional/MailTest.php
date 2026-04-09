<?php

namespace App\Tests;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class MailTest extends WebTestCase
{
    public function testSendMail(): void
    {
        $client = static::createClient();
        $client->request('GET', '/send-mail');

        $this->assertResponseIsSuccessful();
        $this->assertEmailCount(1);
    }
}
