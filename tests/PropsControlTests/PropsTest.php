<?php declare (strict_types = 1);

namespace Wavevision\PropsControlTests;

use Nette\Schema\ValidationException;
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\TestCase;
use Wavevision\PropsControl\Props;
use Wavevision\PropsControlTests\Components\TestComponent\TestComponentProps;

#[CoversClass(Props::class)]
class PropsTest extends TestCase
{

	public function testProcess(): void
	{
		$props = new TestComponentProps([]);
		$this->expectException(ValidationException::class);
		$props->process();
	}

}
